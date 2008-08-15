module AMEE
  class DataObject < AMEE::Object
    
    def full_path
      "/data#{@path}"
    end
      
  end
end