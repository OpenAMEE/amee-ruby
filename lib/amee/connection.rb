# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'typhoeus'
require 'json'
require 'log_buddy'



# LogBuddy.init :log_to_stdout => false
LogBuddy.init :disabled => true
# Set this to true to output curl debug messages in development
DEBUG = false

module AMEE
  class Connection

    include ParseHelper

    RootCA = File.dirname(__FILE__) + '/../../cacert.pem'

    def initialize(server, username, password, options = {})
      unless options.is_a?(Hash)
        raise AMEE::ArgumentError.new("Fourth argument must be a hash of options!")
      end
      
      @server = server
      @username = username
      @password = password
      @ssl = (options[:ssl] == false) ? false : true
      @port = @ssl ? 443 : 80
      @auth_token = nil
      @format = options[:format] || (defined?(JSON) ? :json : :xml)
      @amee_source = options[:amee_source]
      @retries = options[:retries] || 0
      if !valid?
       raise "You must supply connection details - server, username and password are all required!"
      end

      # Working with caching

      # Handle old option
      if options[:enable_caching]
        Kernel.warn '[DEPRECATED] :enable_caching => true is deprecated. Use :cache => :memory_store instead'
        options[:cache] ||= :memory_store
      end
      # Create cache store
      if options[:cache] &&
        (options[:cache_store].class.name == "ActiveSupport::Cache::MemCacheStore" ||
         options[:cache].to_sym == :mem_cache_store)
        raise 'ActiveSupport::Cache::MemCacheStore is not supported, as it doesn\'t allow regexp expiry'
      end
      if options[:cache_store].is_a?(ActiveSupport::Cache::Store)
        # Allows assignment of the entire cache store in Rails apps
        @cache = options[:cache_store]
      elsif options[:cache]
        if options[:cache_options]
          @cache = ActiveSupport::Cache.lookup_store(options[:cache].to_sym, options[:cache_options])
        else
          @cache = ActiveSupport::Cache.lookup_store(options[:cache].to_sym)
        end
      end

      # set up hash to pass to builder block
      @params = {
        :ssl => @ssl,
        :params => {},
        :headers => {}
      }

      if @ssl == true
        @params[:ssl] = true
        if File.exists? RootCA
          @params[:ca_file] = RootCA
        end
      end
      
      self.timeout = options[:timeout] || 60
      @debug = options[:enable_debug]
    end

    attr_reader :format
    attr_reader :server
    attr_reader :username
    attr_reader :password
    attr_reader :retries
    attr_accessor :auth_token #Only used in tests really

    def timeout
      @params[:timeout]
    end

    def timeout=(t)
      @params[:open_timeout] = @params[:timeout] = t
    end

    def version
      authenticate if @version.nil?
      @version
    end

    def valid?
      @username && @password && @server
    end

    # check if we have a valid authentication token
    def authenticated?
      @auth_token =~ /^.*$/
    end

    # GET data from the API, passing in a hash of parameters
    def get(path, data = {})
      # Allow format override
      format = data.delete(:format) || @format
      # Add parameters to URL query string
      get_params = {
        :method => "get", 
        :verbose => DEBUG
      }
      get_params[:params] = data unless data.empty?
      # Create GET request
      get = Typhoeus::Request.new("#{protocol}#{@server}#{path}", get_params)
      # Send request
      do_request(get, format, :cache => true)
    end

    # POST to the AMEE API, passing in a hash of values
    def post(path, data = {})
      # Allow format override
      format = data.delete(:format) || @format
      # Clear cache
      expire_matching "#{raw_path(path)}.*"
      # Extract return unit params
      query_params = {}
      query_params[:returnUnit] = data.delete(:returnUnit) if data[:returnUnit]
      query_params[:returnPerUnit] = data.delete(:returnPerUnit) if data[:returnPerUnit]
      # Create POST request
      post_params = {
        :verbose => DEBUG,
        :method => "post",
        :body => form_encode(data)
      }
      post_params[:params] = query_params unless query_params.empty?
      post = Typhoeus::Request.new("#{protocol}#{@server}#{path}", post_params)
      # Send request
      do_request(post, format)      
    end

    # POST to the AMEE API, passing in a string of data
    def raw_post(path, body, options = {})
      # Allow format override
      format = options.delete(:format) || @format
      # Clear cache
      expire_matching "#{raw_path(path)}.*"
      # Create POST request
      post = Typhoeus::Request.new("#{protocol}#{@server}#{path}", 
        :verbose => DEBUG,
        :method => "post",
        :body => body,
        :headers => { :'Content-type' => options[:content_type] || content_type(format)  }
      )

      # Send request
      do_request(post, format)
    end

    # PUT to the AMEE API, passing in a hash of data
    def put(path, data = {})
      # Allow format override
      format = data.delete(:format) || @format
      # Clear cache
      expire_matching "#{parent_path(path)}.*"
      # Extract return unit params
      query_params = {}
      query_params[:returnUnit] = data.delete(:returnUnit) if data[:returnUnit]
      query_params[:returnPerUnit] = data.delete(:returnPerUnit) if data[:returnPerUnit]
      # Create PUT request
      put_params = {
        :verbose => DEBUG,
        :method => "put",
        :body => form_encode(data)
      }
      put_params[:params] = query_params unless query_params.empty?
      put = Typhoeus::Request.new("#{protocol}#{@server}#{path}", put_params)
       # Send request
      do_request(put, format)
    end

    # PUT to the AMEE API, passing in a string of data
    def raw_put(path, body, options = {})
      # Allow format override
      format = options.delete(:format) || @format
      # Clear cache
      expire_matching "#{parent_path(path)}.*"
      # Create PUT request
      put = Typhoeus::Request.new("#{protocol}#{@server}#{path}", 
        :verbose => DEBUG,
        :method => "put",
        :body => body,
        :headers => { :'Content-type' => options[:content_type] || content_type(format)  }
      )
      # Send request
      do_request(put, format)
    end

    def delete(path)
      # Clear cache
      expire_matching "#{parent_path(path)}.*"
      # Create DELETE request
      delete = Typhoeus::Request.new("#{protocol}#{@server}#{path}", 
        :verbose => DEBUG,
        :method => "delete"
      )
     # Send request
      do_request(delete)
    end

    # Post to the sign in resource on the API, so that all future 
    # requests are signed
    def authenticate
      # :x_amee_source = "X-AMEE-Source".to_sym
      request = Typhoeus::Request.new("#{protocol}#{@server}/auth/signIn", 
        :method => "post",
        :verbose => DEBUG,
        :headers => {
          :Accept => content_type(:xml),
        },
        :body => form_encode(:username=>@username, :password=>@password)
      )

      hydra.queue(request)
      hydra.run
      response = request.response

      @auth_token = response.headers_hash['AuthToken']
      d {request.url}
      d {response.code}
      d {@auth_token}

      connection_failed if response.code == 0

      unless authenticated?
        raise AMEE::AuthFailed.new("Authentication failed. Please check your username and password. (tried #{@username},#{@password})")
      end
      # Detect API version
      if response.body.is_json?
        @version = JSON.parse(response.body)["user"]["apiVersion"].to_f
      elsif response.body.is_xml?
        doc = load_xml_doc(response.body)
        @version = x('/Resources/SignInResource/User/ApiVersion/text()', :doc => doc).to_f
      else
        @version = 1.0
      end
    end

    protected

    def protocol
      @ssl == true ? 'https://' : 'http://'
    end

    # Encode a hash into a application/x-www-form-urlencoded format
    def form_encode(data)
      data.map { |datum|
        "#{CGI::escape(datum[0].to_s)}=#{CGI::escape(datum[1].to_s)}"
      }.join('&')
    end
    
    ## set up the hydra for running http requests. Increase concurrency as needed
    def hydra
      @hydra ||= Typhoeus::Hydra.new(:max_concurrency => 1)
    end

    def content_type(format = @format)
      case format
      when :xml
        return 'application/xml'
      when :json
        return 'application/json'
      when :atom
        return 'application/atom+xml'
      end
    end

    def redirect?(response)
      response.code == 301 || response.code == 302
    end
    
    def connection_failed
      raise AMEE::ConnectionFailed.new("Connection failed. Check server name or network connection.")
    end
    
    # run each request through some basic error checking, and 
    # if needed log requests
    def response_ok?(response, request)
      
      # first allow for debugging
      d {request.object_id}
      d {request}
      d {response.object_id}
      d {response.code}
      d {response.headers_hash}
      d {response.body}

      case response.code.to_i

      when 502, 503, 504
          raise AMEE::ConnectionFailed.new("A connection error occurred while talking to AMEE: HTTP response code #{response.code}.\nRequest: #{request.method.upcase} #{request.url.gsub(request.host, '')}")
      when 408
        raise AMEE::TimeOut.new("Request timed out.")
      when 404
        raise AMEE::NotFound.new("The URL was not found on the server.\nRequest: #{request.method.upcase} #{request.url.gsub(request.host, '')}")
      when 403
        raise AMEE::PermissionDenied.new("You do not have permission to perform the requested operation.\nRequest: #{request.method.upcase} #{request.url.gsub(request.host, '')}\n#{request.body}\Response: #{response.body}")
      when 401
        authenticate
        return false
      when 400
        if response.body.include? "would have resulted in a duplicate resource being created"
          raise AMEE::DuplicateResource.new("The specified resource already exists. This is most often caused by creating an item that overlaps another in time.\nRequest: #{request.method.upcase} #{request.url.gsub(request.host, '')}\n#{request.body}\Response: #{response.body}")
        else
          raise AMEE::BadRequest.new("Bad request. This is probably due to malformed input data.\nRequest: #{request.method.upcase} #{request.url.gsub(request.host, '')}\n#{request.body}\Response: #{response.body}")
        end
      when 200, 201, 204
        return response
      when 0
        connection_failed
      end
      # If we get here, something unhandled has happened, so raise an unknown error.
      raise AMEE::UnknownError.new("An error occurred while talking to AMEE: HTTP response code #{response.code}.\nRequest: #{request.method.upcase} #{request.url}\n#{request.body}\Response: #{response.body}")
    end

    # Wrapper for sending requests through to the API.
    # Takes care of making sure requests authenticated, and 
    # if set, attempts to retry a number of times set when
    # initialising the class
    def do_request(request, format = @format, options = {})

      # Is this a v3 request?
      v3_request = request.url.include?("/#{v3_hostname}/")

      # make sure we have our auth token before we start
      # any v1 or v2 requests
      if !@auth_token && !v3_request
        d "Authenticating first before we hit #{request.url}"
        authenticate 
      end

      request.headers['Accept'] = content_type(format)
      # Set AMEE source header if set
      request.headers['X-AMEE-Source'] = @amee_source if @amee_source

      # path+query string only (split with an int limits the number of splits)
      path_and_query = '/' + request.url.split('/', 4)[3]

      if options[:cache]
        # Get response with caching
        response = cache(path_and_query) { run_request(request, :xml) }
      else
        response = run_request(request, :xml)
      end
      response
    end

    # run request. Extracted from do_request to make
    # cache code simpler
    def run_request(request, format)
      # Is this a v3 request?
      v3_request = request.url.include?("/#{v3_hostname}/")
      # Execute with retries
      retries = [1] * @retries
      begin 
        begin
          d "Queuing the request for #{request.url}"
          add_authentication_to(request) if @auth_token && !v3_request
          hydra.queue request
          hydra.run
          # Return response if OK
        end while !response_ok?(request.response, request)
        # Store updated authToken
        @auth_token = request.response.headers_hash['AuthToken']
        return request.response
      rescue AMEE::ConnectionFailed, AMEE::TimeOut => e
        if delay = retries.shift
          sleep delay
          retry
        else
          raise
        end
      end
    end
    
    # Take an existing request, and add authentication
    # may no longer be needed now that we authenticate before 
    # making a request anyway
    def add_authentication_to(request=nil)
      if @auth_token
        request.headers['Cookie'] = "AuthToken=#{@auth_token}"
        request.headers['AuthToken'] = @auth_token
      else
        raise "The connection can't authenticate. Check if the auth_token is being set by the server"
      end
    end

    def cache(path, &block)
      key = cache_key(path)
      if @cache && @cache.exist?(key)
        d "CACHE HIT on #{key}" if @debug
        return @cache.read(key)
      end
      d "CACHE MISS on #{key}" if @debug
      data = block.call
      @cache.write(key, data) if @cache
      return data
    end

    def parent_path(path)
      path.split('/')[0..-2].join('/')
    end

    def raw_path(path)
      path.split(/[;?]/)[0]
    end

    def cache_key(path)
      # We have to make sure cache keys don't get too long for the filesystem,
      # so we cut them off if they're too long and add a digest for uniqueness.
      key = @server + path.gsub(/[^0-9a-z\/]/i, '').gsub(/\//i, '_')
      key = (key.length < 250) ? key : key.first(218)+Digest::MD5.hexdigest(key)
    end

    public

    def expire(path, options = nil)
      @cache.delete(cache_key(path), options) if @cache
    end

    def expire_matching(matcher, options = nil)
      @cache.delete_matched(Regexp.new(cache_key(matcher)), options) if @cache
    end

    def expire_all
      @cache.clear if @cache
    end

  end
end
