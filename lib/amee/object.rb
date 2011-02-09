module AMEE
  class Object
    include ParseHelper
    extend ParseHelper # because sometimes things parse themselves in class methdos
    def initialize(data = nil)
      @uid = data ? data[:uid] : nil
      @created = data ? data[:created] : Time.now
      @modified = data ? data[:modified] : @created
      @path = data ? data[:path] : nil
      @name = data ? data[:name] : nil
      @connection = data ? data[:connection] : nil
    end

    attr_accessor :connection
    attr_reader :uid
    attr_reader :created
    attr_reader :modified
    attr_reader :path
    attr_reader :name

    def expire_cache
      @connection.expire_matching(full_path+'.*')
    end
    
    # A nice shared get/parse handler that handles retry on parse errors
    def self.get_and_parse(connection, path, options)
      # Note that we don't check the number of times retry has been done lower down
      # and count separately instead.
      # Worst case could be retries squared given the right pattern of failure, but
      # that seems unlikely. Would need, for instance, repeated 503 503 200->parse_fail
      retries = [1] * connection.retries
      begin
        # Load data from path
        response = connection.get(path, options).body
        # Parse data from response
        x = nil
        if response.is_json?
          from_json(response)
        else
          from_xml(response)
        end
      rescue JSON::ParserError, Nokogiri::XML::SyntaxError, REXML::ParseException => e
        # Invalid JSON or XML received, try the GET again in case it got cut off mid-stream
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