module AMEE
  class Collection < Array
    include ParseHelper
    attr_reader :pager,:connection,:doc,:json,:response
    def initialize(connection, options = {})
      # Load data from path
      @options=options
      @max=options.delete :resultMax
      @connection=connection
      # Parse data from response     
      each_page do
        parse_page
      end
    rescue => err
      #raise AMEE::BadData.new("Couldn't load #{self.class.name}.\n#{response} due to #{err}")
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
        REXML::XPath.first(doc,xmlcollectorpath.split('/')[1...-1].join('/')) or
          raise AMEE::BadData.new("Couldn't load #{self.class.name}.\n#{response}")
        REXML::XPath.each(doc, xmlcollectorpath) do |p|
          obj=klass.new(parse_xml(p))
          obj.connection = connection
          self << obj
          break if @max&&length>=@max
        end
      end
    end

    def fetch
      @options.merge! @pager.options if @pager
      @response= @connection.get(collectionpath, @options).body
      if @response.is_json?
        @json = true
        @doc = JSON.parse(@response)
      else
        @doc = REXML::Document.new(@response)
      end
    end

    def each_page
      begin           
        fetch
        yield
        if json
          @pager = AMEE::Pager.from_json(doc['pager'])
        else
          @pager = AMEE::Pager.from_xml(REXML::XPath.first(doc, '/Resources//Pager'))
        end
        break if @max && length>=@max
      end while @pager && @pager.next! #pager is nil if no pager in response,
      # pager.next! is false if @pager said current=last.
    end
  end
end

