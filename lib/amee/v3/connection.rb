# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'active_support/core_ext/string'

module AMEE
  class Connection

    def self.api_version
      '3'
    end

    def v3_defaults
      {
        :verbose => DEBUG,
        :follow_location => true,
        :username => @username,
        :password => @password        
      }
    end

    def v3_get(path, options = {})
      # Create URL parameters
      unless options.empty?
        path += "?" + options.map { |x| "#{CGI::escape(x[0].to_s)}=#{CGI::escape(x[1].to_s)}" }.join('&')
      end

      get_params = {:method => "get"}
      params = v3_defaults.merge(get_params)

      get = Typhoeus::Request.new("https://#{v3_hostname}#{path}", params)

      # Send request
      cache(path) { do_request(get, format) }
    end

    def v3_put(path, options = {})
      expire_matching "#{parent_path(path)}.*"

      # if options[:body]
      #   put.body = options[:body]
      #   put['Content-Type'] = content_type :xml if options[:body].is_xml?
      #   put['Content-Type'] = content_type :json if options[:body].is_json?
      # else

      body = []
      data.each_pair do |key, value|
        body << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
      end

      put_params = { 
        :method => "put",
        :body => body
      }
      params = v3_defaults.merge(put_params)

      put = Typhoeus::Request.new("https://#{v3_hostname}#{path}", params)

      v3_do_request(put, hydra)

    end

    def v3_post(path, options = {})

      expire_matching "#{raw_path(path)}.*"

      body = []
      options.each_pair do |key, value|
        body << "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"
      end

      post_params = {
        :headers => {
        :Accept => 'application/xml',
      },
      :method => "post",
      :body => body.join('&')
      }

      params = v3_defaults.merge(post_params)
      post = Typhoeus::Request.new("https://#{v3_hostname}#{path}", params)

      v3_do_request(post, hydra)
    end

    def v3_delete(path, options = {})
      expire_matching "#{parent_path(path)}.*"
      
      delete_params = { :method => "delete" }
      params = v3_defaults.merge(delete_params)

      delete = Typhoeus::Request.new("https://#{v3_hostname}#{path}", params )
      v3_do_request(delete, hydra)
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

      def v3_response_ok?(response, request)

        case response.code.to_s
        when '200', '201', '204'
          return true
        when '404'
          raise AMEE::NotFound.new("The URL was not found on the server.\nRequest: #{request.method} #{request.url}")
        when '403'
          raise AMEE::PermissionDenied.new("You do not have permission to perform the requested operation.\nRequest: #{request.method} #{request.url}\n#{request.body}\Response: #{response.body}")
        when '401'
          raise AMEE::AuthFailed.new("Authentication failed. Please check your username and password.")
        when '400'
          raise AMEE::BadRequest.new("Bad request. This is probably due to malformed input data.\nRequest: #{request.method} #{request.url}\n#{request.body}\Response: #{response.body}")
        end
        raise AMEE::UnknownError.new("An error occurred while talking to AMEE: HTTP response code #{response.code}.\nRequest: #{request.method} #{request.url}\n#{request.body}\Response: #{response.body}")
      end
      
      def v3_do_request(request, hydra)

        retries = [1] * @retries
        begin 
          d "Queuing the request for #{request.url}"
          hydra.queue request
          hydra.run

          if v3_response_ok?(request.response, request)
            return request.response
          end

        rescue AMEE::ConnectionFailed, AMEE::TimeOut => e
          if delay = retries.shift
            sleep delay
            retry
          else
            raise
          end
        end
      end
      
  end
end
