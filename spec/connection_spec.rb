require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Connection do
  
  before(:each) do
    require 'yaml'
    @amee_config = YAML.load_file("#{File.dirname(__FILE__)}/../config/amee.yml")
  end
  
  it "should be created with url, username and password" do
    c = AMEE::Connection.new(@amee_config['url'], @amee_config['username'], @amee_config['password'])
    c.should be_valid
  end
  
end