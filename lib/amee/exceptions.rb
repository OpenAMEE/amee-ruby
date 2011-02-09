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
        ([@msg, @last_err.message]+@last_err.backtrace).join "\n"
      else
        super
      end
    end
  end
  
  class BadRequest < Exception
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

  class Deprecated < Exception
  end
  
  # These are used to classify exceptions that can occur during parsing
  
  module XMLParseError
  end
  
  module JSONParseError
  end
  
end

# Set up possible XML parse errors
[
  Exception
].each do |m| 
  m.send(:include, AMEE::XMLParseError)
end

# Set up possible JSON parse errors
[
  Exception
].each do |m| 
  m.send(:include, AMEE::JSONParseError)
end

