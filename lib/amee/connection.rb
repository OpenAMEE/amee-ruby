require 'net/http'
require 'net/https'

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
      if !valid?
       raise "You must supply connection details - server, username and password are all required!"
      end
      @enable_caching = options[:enable_caching]
      if @enable_caching
        $cache ||= {}
      end
      # Make connection to server
      @http = Net::HTTP.new(@server, @port)
      if @ssl == true
        @http.use_ssl = true
        if File.exists? RootCA
          @http.ca_file = RootCA
          @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          @http.verify_depth = 5
        end
      end
      @http.read_timeout = 60
      @http.set_debug_output($stdout) if options[:enable_debug]
      @debug = options[:enable_debug]
    end

    attr_reader :format
    attr_reader :server
    attr_reader :username
    attr_reader :password

    def timeout
      @http.read_timeout
    end

    def timeout=(t)
      @http.read_timeout = t
    end

    def version
      authenticate if @version.nil?
      @version
    end

    def valid?
      @username && @password && @server
    end

    def authenticated?
      !@auth_token.nil?
    end

    def get(path, data = {})
      # Allow format override
      format = data.delete(:format) || @format
      # Create URL parameters
      params = []
      data.each_pair do |key, value|
        params << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
      end
      if params.size > 0
        path += "?#{params.join('&')}"
      end
      # Send request
      return $cache[path] if @enable_caching and $cache[path]
      response = do_request(Net::HTTP::Get.new(path), format)
      $cache[path] = response if @enable_caching
      return response
    end

    def post(path, data = {})
      # Allow format override
      format = data.delete(:format) || @format
      # Clear cache
      clear_cache
      # Create POST request
      post = Net::HTTP::Post.new(path)
      body = []
        data.each_pair do |key, value|
        body << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
      end
      post.body = body.join '&'
      # Send request
      do_request(post, format)
    end

    def raw_post(path, body, options = {})
      # Allow format override
      format = options.delete(:format) || @format
      # Clear cache
      clear_cache
      # Create POST request
      post = Net::HTTP::Post.new(path)
      post['Content-type'] = options[:content_type] || content_type(format)
      post.body = body
      # Send request
      do_request(post, format)
    end

    def put(path, data = {})
      # Allow format override
      format = data.delete(:format) || @format
      # Clear cache
      clear_cache
      # Create PUT request
      put = Net::HTTP::Put.new(path)
      body = []
        data.each_pair do |key, value|
        body << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
      end
      put.body = body.join '&'
      # Send request
      do_request(put, format)
    end

    def raw_put(path, body, options = {})
      # Allow format override
      format = options.delete(:format) || @format
      # Clear cache
      clear_cache
      # Create PUT request
      put = Net::HTTP::Put.new(path)
      put['Content-type'] = options[:content_type] || content_type(format)
      put.body = body
      # Send request
      do_request(put, format)
    end

    def delete(path)
      clear_cache
      # Create DELETE request
      delete = Net::HTTP::Delete.new(path)
      # Send request
      do_request(delete)
    end

    def authenticate
      response = nil
      post = Net::HTTP::Post.new("/auth/signIn")
      post.body = "username=#{@username}&password=#{@password}"
      post['Accept'] = content_type(:xml)
      post['X-AMEE-Source'] = @amee_source if @amee_source
      response = @http.request(post)
      @auth_token = response['authToken']
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
      response.code == '301' || response.code == '302'
    end

    def response_ok?(response, request)
      case response.code
        when '200', '201'
          return true
        when '404'
          raise AMEE::NotFound.new("The URL was not found on the server.\nRequest: #{request.method} #{request.path}")
        when '403'
          raise AMEE::PermissionDenied.new("You do not have permission to perform the requested operation.\nRequest: #{request.method} #{request.path}\n#{request.body}\Response: #{response.body}")
        when '401'
          authenticate
          return false
        when '400'
          if response.body.include? "would have resulted in a duplicate resource being created"
            raise AMEE::DuplicateResource.new("The specified resource already exists. This is most often caused by creating an item that overlaps another in time.\nRequest: #{request.method} #{request.path}\n#{request.body}\Response: #{response.body}")
          else
            raise AMEE::UnknownError.new("An error occurred while talking to AMEE: HTTP response code #{response.code}.\nRequest: #{request.method} #{request.path}\n#{request.body}\Response: #{response.body}")
          end
        else
          raise AMEE::UnknownError.new("An error occurred while talking to AMEE: HTTP response code #{response.code}.\nRequest: #{request.method} #{request.path}\n#{request.body}\Response: #{response.body}")
      end
    end

    def do_request(request, format = @format)
      # Open HTTP connection
      @http.start
      # Do request
      begin
        timethen=Time.now
        response = send_request(request, format)
        Logger.log.debug("Requesting #{request.class} at #{request.path} with #{request.body} in format #{format}, taking #{(Time.now-timethen)*1000} miliseconds")
      end while !response_ok?(response, request)
      # Return response
      return response
    rescue SocketError
      raise AMEE::ConnectionFailed.new("Connection failed. Check server name or network connection.")
    ensure
      # Close HTTP connection
      @http.finish if @http.started?
    end

    def send_request(request, format = @format)
      # Set auth token in cookie (and header just in case someone's stripping cookies)
      request['Cookie'] = "authToken=#{@auth_token}"
      request['authToken'] = @auth_token
      # Set accept header
      request['Accept'] = content_type(format)
      # Set AMEE source header if set
      request['X-AMEE-Source'] = @amee_source if @amee_source
      # Do the business
      response = @http.request(request)
      # Done
      response
    end

    public

    def clear_cache
      if @enable_caching
        $cache = {}
      end
    end

  end
end
