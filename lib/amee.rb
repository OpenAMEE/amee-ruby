require 'rexml/document'

# We don't NEED the JSON gem, but if it's available, use it.
begin
  require 'json'
rescue LoadError
  nil
end

require 'amee/version'
require 'amee/exceptions'
require 'amee/connection'
require 'amee/object'
require 'amee/data_category'
require 'amee/data_item'
require 'amee/data_item_value'
require 'amee/profile'
