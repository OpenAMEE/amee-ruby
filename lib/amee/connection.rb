require 'net/http'

module AMEE
  class Connection
    
    def initialize(server, username = nil, password = nil)
      @server = server
      @username = username
      @password = password
      @auth_token = nil
      raise "Must specify both username and password for authenticated access" if (@username || @password) && !valid?
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
      http = Net::HTTP.new(@server)
      http.start do
        get = Net::HTTP::Get.new(path)
        get['authToken'] = @auth_token
        response = http.request(get)
        # If request fails (AMEE returns a 302 for some reason), authenticate and try again
        if response.code == '302'
          authenticate
          get['authToken'] = @auth_token
          response = http.request(get)
        end
      end
      yield response if block_given?
      response
    end

  protected

    def authenticate
      return unless can_authenticate?
      response = nil
      http = Net::HTTP.new(@server)
      http.start do
        response = http.post("/auth", "username=#{@username}&password=#{@password}")
        @auth_token = response['authToken'] if response['authToken']
      end
    end
    
  end
end
