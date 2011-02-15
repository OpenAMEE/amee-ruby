module AMEE
  class Collection < Array
    include ParseHelper
    attr_reader :pager,:connection,:doc,:json,:response
    def initialize(connection, options = {}, &block)
      # Load data from path
      @options=options
      @max=options.delete :resultMax
      @connection=connection
      @filter = block
      # Parse data from response     
      each_page do
        parse_page
      end
    rescue JSONParseError, XMLParseError => err
      raise AMEE::BadData.new("Couldn't load #{self.class.name}.\n#{response}")
    end

    def parse_page
      if json
        jsoncollector.each do |p|
          obj = klass.new(parse_json(p))
          obj.connection = connection
          self << obj
          break if @max&&length>=@max
        end
      else
        doc.xpath(xmlcollectorpath.split('/')[1...-1].join('/')).first or
          raise AMEE::BadData.new("Couldn't load #{self.class.name}. parp\n#{response}")
        doc.xpath(xmlcollectorpath).each do |p|
          obj=klass.new(parse_xml(p))
          obj.connection = connection
          x= @filter ? @filter.call(obj) : obj
          self << x if x
          break if @max&&length>=@max
        end
      end
    end

    def fetch
      @options.merge! @pager.options if @pager
      retries = [1] * connection.retries
      begin
        @response= @connection.get(collectionpath, @options).body
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

    def each_page
      begin           
        fetch
        yield
        if json
          @pager = AMEE::Pager.from_json(doc['pager'])
        else
          @pager = AMEE::Pager.from_xml(doc.xpath('/Resources//Pager').first)
        end
        break if @max && length>=@max
      end while @pager && @pager.next! #pager is nil if no pager in response,
      # pager.next! is false if @pager said current=last.
    end
  end
end

