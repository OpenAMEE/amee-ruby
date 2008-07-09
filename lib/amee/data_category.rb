module AMEE
  module Data
    class Category < AMEE::Object

      def initialize(data = {})
        @children = data ? data[:children] : []
        @items = data ? data[:items] : []
        super
      end

      attr_reader :children
      attr_reader :items

    end
  end
end