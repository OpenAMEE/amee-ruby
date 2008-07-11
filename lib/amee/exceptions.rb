module AMEE
  
  class BadData < Exception
  end
  
  class AuthFailed < Exception  
  end

  class AuthRequired < Exception
  end

  class ConnectionFailed < Exception
  end
  
  class NotFound < Exception
  end
  
end