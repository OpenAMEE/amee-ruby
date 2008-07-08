module AMEE
  module Data
    class Category < AMEE::Object

      def initialize(data = {})
        @path = data ? data[:path] : nil
        super
      end

      attr_reader :path
      
    end
  end
end