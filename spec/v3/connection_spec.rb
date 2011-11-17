# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'

describe AMEE::Connection do

  before :each do
    @c = AMEE::Connection.new('server.example.com', 'username', 'password', :ssl => false)
  end

  it "should have a connection to meta server" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    @c.v3_connection.should_not be_nil
  end

  it "should login and know the path to the server" do
    flexmock(Net::HTTP::Get).new_instances do |mock|
      mock.should_receive(:basic_auth).with('username','password').once
    end
    flexmock(Net::HTTP).should_receive(:new).with('platform-api-server.example.com', 80).once.and_return {
      mock=flexmock
      mock.should_receive(:start => nil)
      mock.should_receive(:started? => true)
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => "OK"))
      mock.should_receive(:finish => nil)
      mock
    }
    @c.v3_get("/#{AMEE::Connection.api_version}/categories/SomeCategory").should == "OK"
  end

  it "should be able to get from meta server" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => "OK"))
      mock.should_receive(:finish => nil)
    end
    @c.v3_get("/#{AMEE::Connection.api_version}/categories/SomeCategory").should == "OK"
  end

  it "should be able to handle failed gets from meta server" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '404'))
      mock.should_receive(:finish => nil)
    end
    lambda {
      @c.v3_get("/#{AMEE::Connection.api_version}/categories/SomeCategory").should == nil
    }.should raise_error(AMEE::NotFound, "The URL was not found on the server.\nRequest: GET /#{AMEE::Connection.api_version}/categories/SomeCategory")
  end

  it "should be able to post to meta server" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => "OK"))
      mock.should_receive(:finish => nil)
    end
    @c.v3_put("/#{AMEE::Connection.api_version}/categories/SomeCategory", {:arg => "test"}).should == "OK"
  end

  it "should be able to handle failed gets from meta server" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '404'))
      mock.should_receive(:finish => nil)
    end
    lambda {
      @c.v3_put("/#{AMEE::Connection.api_version}/categories/SomeCategory", {:arg => "test"}).should == "OK"
    }.should raise_error
  end

  it "should generate correct hostname for platform-dev.amee.com" do
    c = AMEE::Connection.new('platform-dev.amee.com', 'username', 'password')
    c.send(:v3_hostname).should eql 'platform-api-dev.amee.com'
  end

  it "should generate correct hostname for platform-science.amee.com" do
    c = AMEE::Connection.new('platform-science.amee.com', 'username', 'password')
    c.send(:v3_hostname).should eql 'platform-api-science.amee.com'
  end

  it "should generate correct hostname for stage.amee.com" do
    c = AMEE::Connection.new('stage.amee.com', 'username', 'password')
    c.send(:v3_hostname).should eql 'platform-api-stage.amee.com'
  end

  it "should generate correct hostname for live.amee.com" do
    c = AMEE::Connection.new('live.amee.com', 'username', 'password')
    c.send(:v3_hostname).should eql 'platform-api-live.amee.com'
  end

  it "should not change modern hostnames" do
    c = AMEE::Connection.new('platform-api-test.amee.com', 'username', 'password')
    c.send(:v3_hostname).should eql 'platform-api-test.amee.com'
  end

end

describe AMEE::Connection, "with retry enabled" do

  before :each do
    @c = AMEE::Connection.new('server.example.com', 'username', 'password', :ssl => false, :retries => 2)
  end

  [
    Timeout::Error,
    Errno::EINVAL, 
    Errno::ECONNRESET, 
    EOFError,
    Net::HTTPBadResponse, 
    Net::HTTPHeaderSyntaxError, 
    Net::ProtocolError
  ].each do |e|

    it "should retry after #{e.name} the correct number of times" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).and_raise(e.new).twice
        mock.should_receive(:request).and_return(flexmock(:code => '200', :body => '{}')).once
        mock.should_receive(:finish => nil)
      end
      lambda {
        @c.v3_get("/#{AMEE::Connection.api_version}/categories/SomeCategory")
      }.should_not raise_error        
    end

    it "should retry #{e.name} the correct number of times and raise error on failure" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).and_raise(e.new).times(3)
        mock.should_receive(:finish => nil)
      end
      lambda {
        @c.v3_get("/#{AMEE::Connection.api_version}/categories/SomeCategory")
      }.should raise_error(e)
    end
  end
  
  [
    '502',
    '503',
    '504'
  ].each do |e|

    it "should retry after #{e} the correct number of times" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).and_return(flexmock(:code => e, :body => '{}')).twice
        mock.should_receive(:request).and_return(flexmock(:code => '200', :body => '{}')).once
        mock.should_receive(:finish => nil)
      end
      lambda {
        @c.v3_get("/#{AMEE::Connection.api_version}/categories/SomeCategory")
      }.should_not raise_error        
    end

    it "should retry #{e} the correct number of times and raise error on failure" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).and_return(flexmock(:code => e, :body => '{}')).times(3)
        mock.should_receive(:finish => nil)
      end
      lambda {
        @c.v3_get("/#{AMEE::Connection.api_version}/categories/SomeCategory")
      }.should raise_error(AMEE::ConnectionFailed)
    end
  end  
  
end