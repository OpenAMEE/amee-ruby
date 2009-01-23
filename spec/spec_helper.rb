require 'rubygems'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'amee'

Spec::Runner.configure do |config|
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
