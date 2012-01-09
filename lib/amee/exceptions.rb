# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

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

  class TimeOut < Exception
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
  ArgumentError, # thrown by Date.parse
].each do |m| 
  m.send(:include, AMEE::XMLParseError)
end

# Set up possible JSON parse errors
[
  ArgumentError, # thrown by Date.parse,
  NoMethodError, # missing elements in JSON, thrown by nil[]
].each do |m| 
  m.send(:include, AMEE::JSONParseError)
end

