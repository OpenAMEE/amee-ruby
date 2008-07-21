require 'net/http'

module AMEE
  class Connection
    
    def initialize(server, username = nil, password = nil)
      @server = server
      @username = username
      @password = password
      @auth_token = nil
      raise "Must specify both username and password for authenticated access" if (@username || @password) && !valid?
      # Make connection to server
      @http = Net::HTTP.new(@server)
      #@http.set_debug_output($stdout)
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
      @http.start
      get = Net::HTTP::Get.new(path)
      get['authToken'] = @auth_token
      get['Accept'] = 'application/xml'
      response = @http.request(get)
      # Handle 404s
      raise AMEE::NotFound.new("URL doesn't exist on server.") if response.code == '404'
      # If request fails, authenticate and try again
      if authentication_failed?(response)
        authenticate
        get['authToken'] = @auth_token
        response = @http.request(get)
      end
      @http.finish
      yield response.body if block_given?
      response.body
    rescue SocketError
      raise AMEE::ConnectionFailed.new("Connection failed. Check server name or network connection.")
    end

  protected

    def authentication_failed?(response)
      response.code == '401'
    end
    
    def authenticate
      unless can_authenticate?        
        raise AMEE::AuthRequired.new("Authentication required. Please provide your username and password.")
      end
      response = nil
      @http.start
      post = Net::HTTP::Post.new("/auth")
      post.body = "username=#{@username}&password=#{@password}"
      post['Accept'] = 'application/xml'
      response = @http.request(post)
      @auth_token = response['authToken']
      raise AMEE::AuthFailed.new("Authentication failed. Please check your username and password.") unless authenticated?
      @http.finish
    rescue SocketError
      raise AMEE::ConnectionFailed.new("Connection failed. Check server name or network connection.")
    end
    
  end
end
