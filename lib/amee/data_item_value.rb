module AMEE
  module Data
    class ItemValue < AMEE::Object

      def initialize(data = {})
        @path = data ? data[:path] : nil
        @name = data ? data[:name] : nil
        @value = data ? data[:value] : nil
        super
      end

      attr_reader :path
      attr_reader :name
      attr_reader :value
      
    end
  end
end