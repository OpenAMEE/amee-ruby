module AMEE
  module Data
    class Item < AMEE::Object

      def initialize(data = {})
        @path = data ? data[:path] : nil
        @name = data ? data[:name] : nil
        @values = data ? data[:values] : []
        super
      end

      attr_reader :path
      attr_reader :name
      attr_reader :values

    protected
      
      def full_path
        "/data#{@path}"
      end
      
    end
  end
end