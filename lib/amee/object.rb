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

  end
end