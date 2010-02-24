module AMEE
  
  class ArgumentError < Exception
  end

  class BadData < Exception
  end
  
  class AuthFailed < Exception  
  end

  class PermissionDenied < Exception
  end

  class ConnectionFailed < Exception
  end
  
  class NotFound < Exception
  end
  
  class DuplicateResource < Exception
  end

  class UnknownError < Exception
  end

  class NotSupported < Exception
  end
end