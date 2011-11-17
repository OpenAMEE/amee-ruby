# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'active_support/core_ext/string'

module AMEE
  class Connection

    def self.api_version
      '3'
    end
      
    def v3_connection
      @v3_http ||= begin
        @v3_http = Net::HTTP.new(v3_hostname, @port)
        if @ssl == true
          @v3_http.use_ssl = true
          if File.exists? RootCA
            @v3_http.ca_file = RootCA
            @v3_http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            @v3_http.verify_depth = 5
          end
        end
        @v3_http.set_debug_output($stdout) if @debug
        @v3_http
      end
    end    
    def v3_get(path, options = {})
      # Create URL parameters
      unless options.empty?
        path += "?" + options.map { |x| "#{CGI::escape(x[0].to_s)}=#{CGI::escape(x[1].to_s)}" }.join('&')
      end
      cache(path) { v3_request(Net::HTTP::Get.new(path)) }
    end
    def v3_put(path, options = {})
      expire_matching "#{parent_path(path)}.*"
      put = Net::HTTP::Put.new(path)
      if options[:body]
        put.body = options[:body]
        put['Content-Type'] = content_type :xml if options[:body].is_xml?
        put['Content-Type'] = content_type :json if options[:body].is_json?
      else
        put.set_form_data(options)
      end
      v3_request put
    end
    def v3_post(path, options = {})
      expire_matching "#{raw_path(path)}.*"
      post = Net::HTTP::Post.new(path)
      returnobj=options.delete(:returnobj) || false
      post.set_form_data(options)
      v3_request post,returnobj
    end
     def v3_delete(path, options = {})
      expire_matching "#{parent_path(path)}.*"
      delete = Net::HTTP::Delete.new(path)
      v3_request delete
    end
    def v3_auth
      # now the same as v2, i.e.
      [@username,@password]
    end
    private
    def v3_hostname
      unless @server.starts_with?("platform-api-")
        if @server.starts_with?("platform-")
          @server.gsub("platform-", "platform-api-")
        else
          "platform-api-#{@server}"
        end
      else
        @server
      end
    end
    def v3_request(req,returnobj=false)
      # Open HTTP connection
      v3_connection.start
      # Set auth
      req.basic_auth *v3_auth
      # Do request
      timethen=Time.now
      response = send_request(v3_connection, req, :xml)
      Logger.log.debug("Requested #{req.class} at #{req.path} with #{req.body}, taking #{(Time.now-timethen)*1000} miliseconds")
      v3_response_ok? response, req
      returnobj ? response : response.body
    ensure
      v3_connection.finish if v3_connection.started?
    end
 
    def v3_response_ok?(response, request)
      case response.code
        when '200', '201', '204'
          return true
        when '404'
          raise AMEE::NotFound.new("The URL was not found on the server.\nRequest: #{request.method} #{request.path}")
        when '403'
          raise AMEE::PermissionDenied.new("You do not have permission to perform the requested operation.\nRequest: #{request.method} #{request.path}\n#{request.body}\Response: #{response.body}")
        when '401'
          raise AMEE::AuthFailed.new("Authentication failed. Please check your username and password.")
        when '400'
          raise AMEE::BadRequest.new("Bad request. This is probably due to malformed input data.\nRequest: #{request.method} #{request.path}\n#{request.body}\Response: #{response.body}")
      end
      raise AMEE::UnknownError.new("An error occurred while talking to AMEE: HTTP response code #{response.code}.\nRequest: #{request.method} #{request.path}\n#{request.body}\Response: #{response.body}")
    end
  end
end
