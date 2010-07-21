# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Logger do
  it "Should create default error log" do
    AMEE::Logger::log.should be_a Log4r::Logger
    AMEE::Logger::log.debug("Test log message")
  end
  it "Can log to a different logger" do
    AMEE::Logger.to Log4r::Logger.new('Mylogger')
    AMEE::Logger::log.debug("Test log message 2")
  end
end

