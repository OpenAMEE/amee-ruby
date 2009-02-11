require 'net/http'

module AMEE
  class Connection

    def initialize(server, username, password, options = {})
      unless options.is_a?(Hash)
        raise AMEE::ArgumentError.new("Fourth argument must be a hash of options!")
      end
      @server = server
      @username = username
      @password = password
      @auth_token = nil
      @use_json_if_available = options[:use_json_if_available].nil? ? true : options[:use_json_if_available]
      if !valid?
       raise "You must supply connection details - server, username and password are all required!"
      end
      @enable_caching = options[:enable_caching]
      if @enable_caching
        $cache ||= {}
      end
      # Make connection to server
      @http = Net::HTTP.new(@server)
      @http.read_timeout = 5
      @http.set_debug_output($stdout) if options[:enable_debug]
    end
    
    def timeout
      @http.read_timeout
    end
    
    def timeout=(t)
      @http.read_timeout = t
    end

    def version
      @version
    end

    def valid?
      @username && @password && @server
    end
    
    def authenticated?
      !@auth_token.nil?
    end

    def get(path, data = {})
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
      response = do_request Net::HTTP::Get.new(path)
      $cache[path] = response if @enable_caching
      return response
    end
    
    def post(path, data = {})
      clear_cache
      # Create POST request
      post = Net::HTTP::Post.new(path)
      body = []
        data.each_pair do |key, value|
        body << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
      end
      post.body = body.join '&'
      # Send request
      do_request(post)
    end

    def put(path, data = {})
      clear_cache
      # Create PUT request
      put = Net::HTTP::Put.new(path)
      body = []
        data.each_pair do |key, value|
        body << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
      end
      put.body = body.join '&'
      # Send request
      do_request(put)
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
      post = Net::HTTP::Post.new("/auth")
      post.body = "username=#{@username}&password=#{@password}"
      post['Accept'] = content_type
      response = @http.request(post)
      @auth_token = response['authToken']
      unless authenticated?
        raise AMEE::AuthFailed.new("Authentication failed. Please check your username and password.") 
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

    def content_type
      # JSON is not currently implemented reliably for v2, so just use XML
      return 'application/xml' if @version && @version >= 2
      (@use_json_if_available == true && defined?(JSON)) ? 'application/json' : 'application/xml'
    end
    
    def redirect?(response)
      response.code == '301' || response.code == '302'
    end

    def response_ok?(response)
      case response.code
        when '200'
          return true
        when '403'
          raise AMEE::PermissionDenied.new("You do not have permission to perform the requested operation")
        when '401'
          authenticate
          return false
        else
          raise AMEE::UnknownError.new("An error occurred while talking to AMEE: HTTP response code #{response.code}")
      end
    end

    def do_request(request)
      # Open HTTP connection
      @http.start
      # Do request
      begin
        response = send_request(request)
      end while !response_ok?(response)
      # Return body of response
      return response.body
    rescue SocketError
      raise AMEE::ConnectionFailed.new("Connection failed. Check server name or network connection.")
    ensure
      # Close HTTP connection
      @http.finish if @http.started?
    end
        
    def send_request(request)
      request['authToken'] = @auth_token
      request['Accept'] = content_type
      response = @http.request(request)
      # Handle 404s
      if response.code == '404'
        raise AMEE::NotFound.new("URL doesn't exist on server.") 
      end
      # Done
      response
    end

    def clear_cache
      if @enable_caching
        $cache = {}
      end
    end

  end
end
