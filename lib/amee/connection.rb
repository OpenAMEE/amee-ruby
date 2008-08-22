require 'net/http'

module AMEE
  class Connection

    def initialize(server, username = nil, password = nil, use_json_if_available = true)
      @server = server
      @username = username
      @password = password
      @auth_token = nil
      @use_json_if_available = use_json_if_available
      raise "Must specify both username and password for authenticated access" if (@username || @password) && !valid?
      # Make connection to server
      @http = Net::HTTP.new(@server)
      #@http.set_debug_output($stdout)
      @http.start
    rescue SocketError
      raise AMEE::ConnectionFailed.new("Connection failed. Check server name or network connection.")
    end

    def finalize
      @http.finish
    end
    
    def valid?
      !((@username || @password) ? (@username.nil? || @password.nil? || @server.nil?) : @server.nil?)
    end
    
    def can_authenticate?
      !(@username.nil? || @password.nil?)
    end

    def authenticated?
      !@auth_token.nil?
    end

    def get(path)
      response = nil
      get = Net::HTTP::Get.new(path)
      get['authToken'] = @auth_token
      get['Accept'] = content_type
      response = @http.request(get)
      # Handle 404s
      raise AMEE::NotFound.new("URL doesn't exist on server.") if response.code == '404'
      # If request fails, authenticate and try again
      if authentication_failed?(response)
        authenticate
        get['authToken'] = @auth_token
        response = @http.request(get)
      end
      yield response.body if block_given?
      response.body
    end

    def post(path, data = {})
      response = nil
      post = Net::HTTP::Post.new(path)
      post['authToken'] = @auth_token
      post['Accept'] = content_type
      # Add data params to body
      body = []
        data.each_pair do |key, value|
        body << "#{key}=#{value}"
      end
      post.body = body.join '&'
      # Send request
      response = @http.request(post)
      # Handle 404s
      raise AMEE::NotFound.new("URL doesn't exist on server.") if response.code == '404'
      # If request fails, authenticate and try again
      if authentication_failed?(response)
        authenticate
        post['authToken'] = @auth_token
        response = @http.request(post)
      end
      yield response.body if block_given?
      response.body
    end

    def authenticate
      unless can_authenticate?        
        raise AMEE::AuthRequired.new("Authentication required. Please provide your username and password.")
      end
      response = nil
      post = Net::HTTP::Post.new("/auth")
      post.body = "username=#{@username}&password=#{@password}"
      post['Accept'] = content_type
      response = @http.request(post)
      @auth_token = response['authToken']
      raise AMEE::AuthFailed.new("Authentication failed. Please check your username and password.") unless authenticated?
    end

    protected

    def content_type
      (@use_json_if_available && defined?(JSON)) ? 'application/json' : 'application/xml'
    end
    
    def authentication_failed?(response)
      response.code == '401'
    end
        
  end
end
