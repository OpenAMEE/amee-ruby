module AMEE
  
  class ArgumentError < Exception
  end

  class BadData < Exception
    def initialize(msg = nil, err = nil)
      super(msg)
      @msg = msg
      @err = err
    end
    def to_s
      if @err
        [@msg, @err.message, @err.backtrace.first].join "\n"
      else
        super
      end
    end
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