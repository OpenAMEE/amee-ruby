module AMEE
  module Data
    class ItemValue < AMEE::Object

      def initialize(data = {})
        @value = data ? data[:value] : nil
        super
      end

      attr_reader :value
      
    end
  end
end