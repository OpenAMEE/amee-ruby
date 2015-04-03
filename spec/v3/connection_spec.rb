# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'

describe AMEE::Connection do

  before :each do
    @c = AMEE::Connection.new('stage.amee.com', AMEE_V3_API_KEY, AMEE_V3_PASSWORD)
  end

  it "should have a connection to meta server" do
    VCR.use_cassette("AMEE_Connection/v3/should have a connection to meta server") do
      @c.authenticate.should_not be_nil
    end
  end

  it "should login and know the path to the server" do
    VCR.use_cassette("AMEE_Connection/v3/should login and know the path to the server") do
      @c.authenticate.should_not be_nil
    end
  end

  it "should be able to get from meta server" do
    VCR.use_cassette("AMEE_Connection/v3/should be able to get from meta server") do
      @get_request = @c.v3_get("/#{AMEE::Connection.api_version}/categories/Api_test")
      @get_request.include?("<Status>OK</Status>").should be_true
    end
  end

  it "should be able to handle failed gets from meta server" do
    VCR.use_cassette("AMEE_Connection/v3/should be able to handle failed gets from meta server") do
    lambda {
      @c.v3_get("/#{AMEE::Connection.api_version}/categories/SomeCategory").should == nil
    }.should raise_error(AMEE::NotFound, "The URL was not found on the server.\nRequest: GET /#{AMEE::Connection.api_version}/categories/SomeCategory")
  end
  end

  it "should be able to post to meta server" do
    VCR.use_cassette("AMEE_Connection/v3/should be able to post to meta server") do
      @post_request = @c.v3_post("/#{AMEE::Connection.api_version}/categories/039DCB9BA67D/items", {:'values.question' => Time.now.to_i, :returnobj => true})
      @post_request.code.should == 201
    end
  end

  it "should be able to handle failed puts to meta server" do
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
    @c = AMEE::Connection.new('stage.amee.com', AMEE_V3_API_KEY, AMEE_V3_PASSWORD, :retries => 2)

    @timeout_response = {
      :status => 408,
      :body => "",
      :time => 30
    }
    @successful_response = {
      :status => 200,
      :body => "",
      :time => 30
    }

  end

  [
    AMEE::TimeOut
  ].each do |e|

    it "should retry after #{e.name} the correct number of times" do
      
      VCR.use_cassette("AMEE_Connection/v3/retries/#{e.name}") do
        @c.authenticate
      end

      stub_request(:any, /.*#{AMEE::Connection.api_version}\/categories\/Api_test.*/).
            to_return(@timeout_response).times(2).
            then.to_return(@successful_response)
      lambda {
        @c.v3_get("/#{AMEE::Connection.api_version}/categories/Api_test")
      }.should_not raise_error        
    end

    it "should retry #{e.name} the correct number of times and raise error on failure" do

      VCR.use_cassette("AMEE_Connection/v3/retries/#{e.name}") do
        @c.authenticate
      end
      
      stub_request(:any, /.*#{AMEE::Connection.api_version}\/categories\/Api_test.*/).
            to_return(@timeout_response).times(3)

      lambda {
        @c.v3_get("/#{AMEE::Connection.api_version}/categories/Api_test")
      }.should raise_error(e)
    end
  end
  
  [
    '502',
    '503',
    '504'
  ].each do |e|

    it "should retry after #{e} the correct number of times" do

      @successful_response = {
        :status => 200,
        :body => "",
        :time => 30
      }
      
      @error_response = {
        :status => e.to_i,
        :body => "",
      }

      VCR.use_cassette("AMEE_Connection/v3/retries/#{e}") do
        @c.authenticate
      end
      
      stub_request(:any, /.*#{AMEE::Connection.api_version}\/categories\/Api_test.*/).
            to_return(@error_response).times(2).
            then.to_return(@successful_response)
      lambda {
        @c.v3_get("/#{AMEE::Connection.api_version}/categories/Api_test")
      }.should_not raise_error        
    end

    it "should retry #{e} the correct number of times and raise error on failure" do

      @error_response = {
        :status => e.to_i,
        :body => "",
      }

      VCR.use_cassette("AMEE_Connection/v3/retries/#{e}") do
        @c.authenticate
      end
      
      stub_request(:any, /.*#{AMEE::Connection.api_version}\/categories\/Api_test.*/).
            to_return(@error_response).times(3)

      lambda {
        @c.v3_get("/#{AMEE::Connection.api_version}/categories/Api_test")
      }.should raise_error(AMEE::ConnectionFailed)
    end
  end  
  
end
