# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

# Log4r logger for AMEE rubgem
# by default, just log to stderr
# clients can change this thus
# AMEE::Log.to logtothis

module AMEE
  class Logger
    def self.log
      @@log ||= setup_logger
    end
    def self.to(log)
      @@log=log
    end
    
    private
    def self.setup_logger
      log = Log4r::Logger.new('AMEERuby')
      log.outputters = [Log4r::StderrOutputter.new('AMEERubyStdout')]
      log.level=Log4r::WARN
      log
    end
  end
end
