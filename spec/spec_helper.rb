require 'rubygems'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'amee'

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

