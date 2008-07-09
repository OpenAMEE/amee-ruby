module AMEE
  module Data
    class Category < AMEE::Object

      def initialize(data = {})
        @path = data ? data[:path] : nil
        @name = data ? data[:name] : nil
        @children = data ? data[:children] : []
        @items = data ? data[:items] : []
        super
      end

      attr_reader :path
      attr_reader :name
      attr_reader :children
      attr_reader :items

    protected
      
      def full_path
        "/data#{@path}"
      end
      
    end
  end
end