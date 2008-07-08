module AMEE
  class Object
    
    def initialize(data = nil)
      @uid = data ? data[:uid] : nil
      @created = data ? data[:created] : Time.now
      @modified = data ? data[:modified] : @created
    end
    
    attr_reader :uid
    attr_reader :created
    attr_reader :modified
    
  end
end