# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
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
      do_request(get, format)
    end

    # POST to the AMEE API, passing in a hash of values
    def post(path, data = {})
      # Allow format override
      format = data.delete(:format) || @format
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
        @version = REXML::Document.new(response.body).elements['Resources'].elements['SignInResource'].elements['User'].elements['ApiVersion'].text.to_f
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
          raise AMEE::ConnectionFailed.new("A connection error occurred while talking to AMEE: HTTP response code #{response.code}.\nRequest: #{request.url.gsub(request.host, '')}")
      when 408
        raise AMEE::TimeOut.new("Request timed out.")
      when 404
        raise AMEE::NotFound.new("The URL was not found on the server.\nRequest: #{request.url.gsub(request.host, '')}")
      when 403
        raise AMEE::PermissionDenied.new("You do not have permission to perform the requested operation.\nRequest: #{request.url.gsub(request.host, '')}\n#{request.body}\Response: #{response.body}")
      when 401
        raise AMEE::PermissionDenied.new("Not authenticated.\nRequest: #{request.options[:method]} #{request.url.gsub(request.host, '')}\n#{request.body}\Response: #{response.body}")
      when 400
        if response.body.include? "would have resulted in a duplicate resource being created"
          raise AMEE::DuplicateResource.new("The specified resource already exists. This is most often caused by creating an item that overlaps another in time.\nRequest: #{request.url.gsub(request.host, '')}\n#{request.body}\Response: #{response.body}")
        else
          raise AMEE::BadRequest.new("Bad request. This is probably due to malformed input data.\nRequest: #{request.url.gsub(request.host, '')}\n#{request.body}\Response: #{response.body}")
        end
      when 200, 201, 204
        return response
      when 0
        connection_failed
      end
      # If we get here, something unhandled has happened, so raise an unknown error.
      raise AMEE::UnknownError.new("An error occurred while talking to AMEE: HTTP response code #{response.code}.\nRequest: #{request.url}\n#{request.body}\Response: #{response.body}")
    end

    # Wrapper for sending requests through to the API.
    # Takes care of making sure requests authenticated, and 
    # if set, attempts to retry a number of times set when
    # initialising the class
    def do_request(request, format = @format, options = {})
      request.options[:headers]['Accept'] = content_type(format)
      # Set AMEE source header if set
      request.options[:headers]['X-AMEE-Source'] = @amee_source if @amee_source

      # path+query string only (split with an int limits the number of splits)
      path_and_query = '/' + request.url.split('/', 4)[3]

      run_request(request, :xml)
    end

    # run request. Extracted from do_request to make
    # cache code simpler
    def run_request(request, format)
      # Is this a v3 request?
      v3_request = true
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
        request.options[:headers]['Cookie'] = "AuthToken=#{@auth_token}"
        request.options[:headers]['AuthToken'] = @auth_token
      else
        raise "The connection can't authenticate. Check if the auth_token is being set by the server"
      end
    end

    def parent_path(path)
      path.split('/')[0..-2].join('/')
    end

    def raw_path(path)
      path.split(/[;?]/)[0]
    end
  end
end
