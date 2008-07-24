require 'rexml/document'
require 'amee/exceptions'
require 'amee/connection'
require 'amee/object'
require 'amee/data_category'
require 'amee/data_item'
require 'amee/data_item_value'
require 'amee/profile'

module AMEE
  
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 1
    TINY  = 2
    STRING = [MAJOR, MINOR, TINY].join('.')
  end
  
end
