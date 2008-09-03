module AMEE
  module Profile
    class Object < AMEE::Object
    
      def full_path
        "/profiles#{@path}"
      end
      
    end
  end
end