# Log4r logger for AMEE rubgem
# by default, just log to stderr
# clients can change this thus
# AMEE::Log.to logtothis

module AMEE
  module Logger
    @@log=Log4r::Logger.new('AMEERuby')
    @@log.outputters=[Log4r::StderrOutputter.new('AMEERubyStdout')]
    @@log.level=Log4r::WARN
    def self.log
      @@log
    end
    def self.to(log)
      @@log=log
    end
  end
end
