require 'rexml/document'
require 'amee/exceptions'
require 'amee/connection'
require 'amee/object'
require 'amee/data_category'
require 'amee/data_item'
require 'amee/data_item_value'

module AMEE
  
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 1
    TINY  = 1
    STRING = [MAJOR, MINOR, TINY].join('.')
  end
  
end
