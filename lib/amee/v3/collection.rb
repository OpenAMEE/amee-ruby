# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  class Collection < Array

    def v3
      collectionpath=~/^\/3/
    end

    alias_method :fetch_without_v3, :fetch
    def fetch
      @options.merge! @pager.options if @pager
      retries = [1] * connection.retries
      begin
        if @use_v3_connection == true
          @response = @connection.v3_get(collectionpath, @options)
        else
          @response= @connection.get(collectionpath, @options).body
        end
        if @response.is_json?
          @json = true
          @doc = JSON.parse(@response)
        else
          @doc = load_xml_doc(@response)
        end
      rescue JSON::ParserError, Nokogiri::XML::SyntaxError
        @connection.expire(collectionpath)
        if delay = retries.shift
          sleep delay
          retry
        else
          raise
        end
      end
    end

    alias_method :each_page_without_v3, :each_page
    def each_page
      @pager=AMEE::Limiter.new(@options) if v3
      # in v3 need to specify limit to start with, not in v2
      begin           
        fetch
        yield
        if json
          @pager = v3 ? AMEE::Limiter.from_json(doc,@pager.options.merge(@options)) :  # json not built
            AMEE::Pager.from_json(doc['pager'])
        else
          @pager = v3 ? 
               AMEE::Limiter.from_xml(doc.xpath('/Representation/*').first,
               @pager.options.merge(@options)) :
               AMEE::Pager.from_xml(doc.xpath('/Resources//Pager').first)
        end
        break if @max && length>=@max
      end while @pager && @pager.next! #pager is nil if no pager in response,
      # pager.next! is false if @pager said current=last.
    end
  end
end
