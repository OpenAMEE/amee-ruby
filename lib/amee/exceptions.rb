module AMEE
  
  class ArgumentError < Exception
  end

  class BadData < Exception
    def initialize(msg = nil)
      super(msg)
      @msg = msg
      @last_err = $!
    end
    def to_s
      if @last_err
        [@msg, @last_err.message, @last_err.backtrace.first].join "\n"
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