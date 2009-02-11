require 'rexml/document'

# We don't NEED the JSON gem, but if it's available, use it.
begin
  require 'json'
rescue LoadError
  nil
end

class String
  def is_json?
    slice(0,1) == '{'
  end
  def is_xml?
    slice(0,5) == '<?xml'
  end
  def is_v2_xml?
    is_xml? && include?('<Resources xmlns="http://schemas.amee.cc/2.0">')
  end
end

require 'amee/version'
require 'amee/exceptions'
require 'amee/connection'
require 'amee/object'
require 'amee/data_object'
require 'amee/profile_object'
require 'amee/data_category'
require 'amee/data_item'
require 'amee/data_item_value'
require 'amee/profile'
require 'amee/profile_category'
require 'amee/profile_item'
require 'amee/drill_down'

class Date
  def amee2schema
    strftime("%Y-%m-%dT%H:%M+0000")
  end
  def amee1_date
    strftime("%Y%m%d")
  end
  def amee1_month
    strftime("%Y%m")
  end
end

class Time
  def amee2schema
    strftime("%Y-%m-%dT%H:%M+0000")
  end
  def amee1_date
    strftime("%Y%m%d")
  end
  def amee1_month
    strftime("%Y%m")
  end
end