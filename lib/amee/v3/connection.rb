# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'active_support/core_ext/string'

module AMEE
  class Connection

    # API version used in URLs
    def self.api_version
      '3'
    end

    # Perform a GET request
    # options hash should contain query parameters
    def v3_get(path, options = {})
      # Add parameters to URL query string
      unless options.empty?
        path += "?" + form_encode(options)
      end
      # Create request parameters
      get_params = {:method => "get"}
      # Send request (with caching)
      cache(path) { v3_do_request(get_params, path) }
    end

    # Perform a PUT request
    # options hash should contain request body parameters
    def v3_put(path, options = {})
      # Expire cached objects from parent on down
      expire_matching "#{parent_path(path)}.*"
      # Create request parameters
      put_params = { 
        :method => "put",
        :body => form_encode(options)
      }
      # Request
      v3_do_request(put_params, path)
    end

    # Perform a POST request
    # options hash should contain request body parameters
    # It can also contain a :returnobj parameter which will cause
    # a full reponse object to be returned instead of just the body
    def v3_post(path, options = {})
      # Expire cached objects from here on down
      expire_matching "#{raw_path(path)}.*"
      # Get 'return full response object' flag
      return_obj = options.delete(:returnobj) || false
      # Create request parameters
      post_params = {
        :method => "post",
        :body => form_encode(options)
      }
      # Request
      v3_do_request(post_params, path, return_obj)
    end

    # Perform a POST request
    def v3_delete(path)
      # Expire cached objects from here on down
      expire_matching "#{parent_path(path)}.*"
      # Create request parameters
      delete_params = { :method => "delete" }
      # Request
      v3_do_request(delete_params, path)
    end

    private
    
    # Default request parameters
    def v3_defaults
      {
        :verbose => DEBUG,
        :follow_location => true,
        :username => @username,
        :password => @password
      }
    end

    # Encode a hash into a application/x-www-form-urlencoded format
    def form_encode(data)
      data.map { |datum|
        "#{CGI::escape(datum[0].to_s)}=#{CGI::escape(datum[1].to_s)}"
      }.join('&')
    end
    
    # Wrap up parameters into a request and execute it
    def v3_do_request(params, path, return_obj = false)
      req = Typhoeus::Request.new("https://#{v3_hostname}#{path}", v3_defaults.merge(params))
      response = do_request(req, :xml)
      return_obj ? response : response.body
    end
    
    # Work out v3 hostname corresponding to v2 hostname
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
      
  end
end
