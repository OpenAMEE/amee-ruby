require 'net/http'

module AMEE
  class Connection

    def initialize(server, username = nil, password = nil, use_json_if_available = true)
      @server = server
      @username = username
      @password = password
      @auth_token = nil
      @use_json_if_available = use_json_if_available
      if (@username || @password) && !valid?
       raise "Must specify both username and password for authenticated access"
      end
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
      # Send request
      do_request(Net::HTTP::Get.new(path))
    end

    def post(path, data = {})
      # Create POST request
      post = Net::HTTP::Post.new(path)
      body = []
        data.each_pair do |key, value|
        body << "#{key}=#{value}"
      end
      post.body = body.join '&'
      # Send request
      do_request(post)
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
      unless authenticated?
        raise AMEE::AuthFailed.new("Authentication failed. Please check your username and password.") 
      end
    end

    protected

    def content_type
      (@use_json_if_available && defined?(JSON)) ? 'application/json' : 'application/xml'
    end
    
    def authentication_failed?(response)
      response.code == '401'
    end
   
    def do_request(request)
      # Do request
      response = send_request(request)
      # If request fails, authenticate and try again
      if authentication_failed?(response)
        authenticate
        response = send_request(request)
      end
      # Return body of response
      response.body
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

  end
end
