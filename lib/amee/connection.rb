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

    def get(path, data = {})
      # Create URL parameters
      params = []
      data.each_pair do |key, value|
        params << "#{key}=#{value}"
      end
      if params.size > 0
        path += "?#{params.join('&')}"
      end
      # Send request
      do_request Net::HTTP::Get.new(path)
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

    def put(path, data = {})
      # Create PUT request
      put = Net::HTTP::Put.new(path)
      body = []
        data.each_pair do |key, value|
        body << "#{key}=#{value}"
      end
      put.body = body.join '&'
      # Send request
      do_request(put)
    end

    def delete(path)
      # Create DELETE request
      delete = Net::HTTP::Delete.new(path)
      # Send request
      do_request(delete)
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

  end
end
