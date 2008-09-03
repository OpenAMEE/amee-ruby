module AMEE
  module Data
    class Object < AMEE::Object
    
      def full_path
        "/data#{@path}"
      end

    end
  end
end