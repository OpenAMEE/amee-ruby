module AMEE
  class Object
    
    def initialize(data = nil)
      @uid = data ? data[:uid] : nil
      @created = data ? data[:created] : Time.now
      @modified = data ? data[:modified] : @created
      @path = data ? data[:path] : nil
      @name = data ? data[:name] : nil
      @connection = data[:connection]
    end
    
    attr_accessor :connection
    attr_reader :uid
    attr_reader :created
    attr_reader :modified
    attr_reader :path
    attr_reader :name
    
  end
end