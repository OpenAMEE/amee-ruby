require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Connection do
  
  before(:each) do
    require 'yaml'
    @amee_config = YAML.load_file("#{File.dirname(__FILE__)}/../config/amee.yml")
  end
  
  it "can be created with url only" do
    c = AMEE::Connection.new(@amee_config['server'])
    c.should be_valid
  end
  
  it "cannot be created with username but no password" do
    lambda{AMEE::Connection.new(@amee_config['server'], @amee_config['username'])}.should raise_error
  end

  it "cannot be created with password but no username" do
    lambda{AMEE::Connection.new(@amee_config['server'], nil, @amee_config['password'])}.should raise_error
  end

  it "can be created with url, username and password" do
    c = AMEE::Connection.new(@amee_config['server'], @amee_config['username'], @amee_config['password'])
    c.should be_valid
  end

end

describe AMEE::Connection, "with authentication" do
  
  before(:each) do
    require 'yaml'
    amee_config = YAML.load_file("#{File.dirname(__FILE__)}/../config/amee.yml")
    @amee = AMEE::Connection.new(amee_config['server'], amee_config['username'], amee_config['password'])
  end
  
  it "should start out unauthenticated" do
    @amee.authenticated?.should be_false
  end

  it "should be capable of authentication" do
    @amee.can_authenticate?.should be_true
  end

  it "should be able to get private URLs" do
    @amee.get('/data') do |response|
      response.should_not be_empty
    end
    @amee.authenticated?.should be_true
  end

  it "should handle 404s gracefully" do
    lambda{@amee.get('/missing_url')}.should raise_error(AMEE::NotFound, "URL doesn't exist on server.")
  end

end

describe AMEE::Connection, "with incorrect server name" do
  
  it "should raise a useful error" do
    @amee = AMEE::Connection.new('badservername.example.com')
    lambda{@amee.get('/')}.should raise_error(AMEE::ConnectionFailed, "Connection failed. Check server name or network connection.")
  end

end

describe AMEE::Connection, "with bad authentication information" do
  
  before(:each) do
    require 'yaml'
    amee_config = YAML.load_file("#{File.dirname(__FILE__)}/../config/amee.yml")
    @amee = AMEE::Connection.new(amee_config['server'], 'wrong', 'details')
  end
  
  it "should be capable of making requests for public URLs" do
    lambda{@amee.get('/')}.should_not raise_error
  end

  it "should get an authentication failure when accessing private URLs" do
    lambda{@amee.get('/data')}.should raise_error(AMEE::AuthFailed, "Authentication failed. Please check username and password.")
  end

end

describe AMEE::Connection, "without authentication" do
  
  before(:each) do
    require 'yaml'
    amee_config = YAML.load_file("#{File.dirname(__FILE__)}/../config/amee.yml")
    @amee = AMEE::Connection.new(amee_config['server'])
  end
  
  it "should not be capable of authentication" do
    @amee.can_authenticate?.should be_false
  end

  it "should be capable of making requests for public URLs" do
    @amee.get('/') do |response|
      response.should be_empty
    end
    @amee.authenticated?.should be_false
  end

  it "should not be able to get private URLs" do
    lambda{@amee.get('/data')}.should raise_error(AMEE::AuthFailed, "Authentication required. Please provide username and password.")
  end

end