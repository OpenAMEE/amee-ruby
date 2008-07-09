module AMEE
  module Data
    class Item < AMEE::Object

      def initialize(data = {})
        @values = data ? data[:values] : []
        super
      end

      attr_reader :values

    end
  end
end