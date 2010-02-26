module AMEE
  module Data
    class Object < AMEE::Object

      attr_accessor :path
      def full_path
        "/data#{path}"
      end

    end
  end
end