# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'rubygems'
require 'rspec'
require 'logger'
require 'vcr'
require 'pry'
require 'webmock/rspec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'amee'

WebMock.enable!
WebMock.disable_net_connect!

def test_credentials(filename)
  test_creds = File.read File.dirname(__FILE__)+'/../'+filename
  YAML.load(test_creds)
end

AMEE_V1_API_KEY  = test_credentials('amee_test_credentials.yml')['v1']['api_key']
AMEE_V1_PASSWORD = test_credentials('amee_test_credentials.yml')['v1']['password']
AMEE_V2_API_KEY  = test_credentials('amee_test_credentials.yml')['v2']['api_key']
AMEE_V2_PASSWORD = test_credentials('amee_test_credentials.yml')['v2']['password']
AMEE_V3_API_KEY  = test_credentials('amee_test_credentials.yml')['v3']['api_key']
AMEE_V3_PASSWORD = test_credentials('amee_test_credentials.yml')['v3']['password']


VCR.configure do |c|
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.default_cassette_options = { :record => :once }
  c.cassette_library_dir = 'cassettes'
  c.filter_sensitive_data('<AMEE_V1_API_KEY>') { AMEE_V1_API_KEY}
  c.filter_sensitive_data('<AMEE_V1_PASSWORD>') { AMEE_V1_PASSWORD}
  c.filter_sensitive_data('<AMEE_V2_API_KEY>') { AMEE_V2_API_KEY}
  c.filter_sensitive_data('<AMEE_V2_PASSWORD>') { AMEE_V2_PASSWORD}
  c.filter_sensitive_data('<AMEE_V3_API_KEY>') { AMEE_V3_API_KEY }
  c.filter_sensitive_data('<AMEE_V3_PASSWORD>') { AMEE_V3_PASSWORD }
end

RSpec.configure do |config|
  config.mock_with :flexmock
end

# Stub activerecord for rails tests
# Taken from http://muness.blogspot.com/2006/12/unit-testing-rails-activerecord-classes.html
class ActiveRecordUnitTestHelper
 attr_accessor :klass

 def initialize klass
   self.klass = klass
   self
 end

 def where attributes
   klass.stubs(:columns).returns(columns(attributes))
   instance = klass.new(attributes)
   instance.id = attributes[:id] if attributes[:id] #the id attributes works differently on active record classes
   instance
 end

protected
 def columns attributes
   attributes.keys.collect{|attribute| column attribute.to_s, attributes[attribute]}
 end

 def column column_name, value
   ActiveRecord::ConnectionAdapters::Column.new(column_name, nil, ActiveRecordUnitTestHelper.active_record_type(value.class), false)
 end

 def self.active_record_type klass
   return case klass.name
     when "Fixnum"         then "integer"
     when "Float"          then "float"
     when "Time"           then "time"
     when "Date"           then "date"
     when "String"         then "string"
     when "Object"         then "boolean"
   end
 end
end

def disconnected klass
 ActiveRecordUnitTestHelper.new(klass)
end

def fixture(filename)
  File.read File.dirname(__FILE__)+'/fixtures/'+filename
end

XMLPreamble='<?xml version="1.0" encoding="UTF-8"?>'

