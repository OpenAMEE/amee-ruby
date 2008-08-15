module AMEE
  class ProfileObject < AMEE::Object
    
    def full_path
      "/profiles#{@path}"
    end
      
  end
end