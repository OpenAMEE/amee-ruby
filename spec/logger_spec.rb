# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'

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

