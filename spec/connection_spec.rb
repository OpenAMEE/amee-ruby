require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Connection do
  
  it "can be created with url only" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    c = AMEE::Connection.new('server.example.com')
    c.should be_valid
  end
  
  it "cannot be created with username but no password" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    lambda{AMEE::Connection.new('server.example.com', 'username')}.should raise_error
  end

  it "cannot be created with password but no username" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    lambda{AMEE::Connection.new('server.example.com', nil, 'password')}.should raise_error
  end

  it "can be created with url, username and password" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    c = AMEE::Connection.new('server.example.com', 'username', 'password')
    c.should be_valid
  end

end

describe AMEE::Connection, "with authentication" do
  
  it "should start out unauthenticated" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.authenticated?.should be_false
  end

  it "should be capable of authentication" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.can_authenticate?.should be_true
  end

  it "should be able to get private URLs" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '401', :body => ''),
                                               flexmock(:code => '200', :body => '', :'[]' => 'dummy_auth_token_data'),
                                               flexmock(:code => '200', :body => '<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path/><DataCategory created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CD310BEBAC52"><Name>Root</Name><Path/><Environment uid="5F5887BCF726"/></DataCategory><Children><DataCategories><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><DataCategory uid="9E5362EAB0E7"><Name>Metadata</Name><Path>metadata</Path></DataCategory><DataCategory uid="6153F468BE05"><Name>Test</Name><Path>test</Path></DataCategory><DataCategory uid="263FC0186834"><Name>Transport</Name><Path>transport</Path></DataCategory><DataCategory uid="2957AE9B6E6B"><Name>User</Name><Path>user</Path></DataCategory></DataCategories></Children></DataCategoryResource></Resources>'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.get('/data') do |response|
      response.should_not be_empty
    end
    amee.authenticated?.should be_true
  end

  it "should handle 404s gracefully" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil, :request => flexmock(:code => '404', :body => ""), :finish => nil)
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    lambda{amee.get('/missing_url')}.should raise_error(AMEE::NotFound, "URL doesn't exist on server.")
  end

end

describe AMEE::Connection, "with incorrect server name" do
  
  it "should raise a useful error" do
    flexmock(Net::HTTP).new_instances.should_receive(:start).and_raise(SocketError.new)
    lambda{AMEE::Connection.new('badservername.example.com')}.should raise_error(AMEE::ConnectionFailed, "Connection failed. Check server name or network connection.")
  end

end

describe AMEE::Connection, "with bad authentication information" do
  
  it "should be capable of making requests for public URLs" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil, :request => flexmock(:code => '200', :body => ""), :finish => nil)
    amee = AMEE::Connection.new('server.example.com', 'wrong', 'details')
    lambda{amee.get('/')}.should_not raise_error
  end

  it "should get an authentication failure when accessing private URLs" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil, :request => flexmock(:code => '401', :body => "", :'[]' => nil), :finish => nil)
    amee = AMEE::Connection.new('server.example.com', 'wrong', 'details')
    lambda{amee.get('/data')}.should raise_error(AMEE::AuthFailed, "Authentication failed. Please check your username and password.")
  end

end

describe AMEE::Connection, "without authentication" do
  
  it "should not be capable of authentication" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    amee = AMEE::Connection.new('server.example.com')
    amee.can_authenticate?.should be_false
  end

  it "should be capable of making requests for public URLs" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil, :request => flexmock(:code => '200', :body => ""), :finish => nil)
    amee = AMEE::Connection.new('server.example.com')
    amee.get('/') do |response|
      response.should be_empty
    end
    amee.authenticated?.should be_false
  end

  it "should not be able to get private URLs" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil, :request => flexmock(:code => '401', :body => ""), :finish => nil)
    amee = AMEE::Connection.new('server.example.com')
    lambda{amee.get('/data')}.should raise_error(AMEE::AuthRequired, "Authentication required. Please provide your username and password.")
  end

end