require 'rexml/document'
require 'nokogiri'
require 'active_support'
require 'log4r'

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
  def is_v2_json?
    is_json? && match('"apiVersion"\s?:\s?"2.0"')
  end
  def is_xml?
    slice(0,5) == '<?xml'
  end
  def is_v2_xml?
    is_xml? && include?('<Resources xmlns="http://schemas.amee.cc/2.0">')
  end
  def is_v2_atom?
    is_xml? && (include?('<feed ') || include?('<entry ')) && include?('xmlns:amee="http://schemas.amee.cc/2.0"')
  end
end

require 'amee/logger'
require 'amee/exceptions'
require 'amee/connection'
require 'amee/parse_helper'
require 'amee/collection'
require 'amee/object'
require 'amee/data_object'
require 'amee/profile_object'
require 'amee/data_category'
require 'amee/data_item'
require 'amee/data_item_value'
require 'amee/data_item_value_history'
require 'amee/profile'
require 'amee/profile_category'
require 'amee/profile_item'
require 'amee/profile_item_value'
require 'amee/drill_down'
require 'amee/pager'
require 'amee/item_definition'
require 'amee/item_value_definition'
require 'amee/user'
require 'amee/v3'

class Date
  def amee1_date
    strftime("%Y%m%d")
  end
  def amee1_month
    strftime("%Y%m")
  end
end

class Time
  def amee1_date
    strftime("%Y%m%d")
  end
  def amee1_month
    strftime("%Y%m")
  end
end
