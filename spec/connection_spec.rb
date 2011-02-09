require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Connection do

  it "requires server name, username, and password" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    lambda{AMEE::Connection.new(nil, nil, nil)}.should raise_error
    lambda{AMEE::Connection.new(nil, 'username', nil)}.should raise_error
    lambda{AMEE::Connection.new(nil, nil, 'password')}.should raise_error
    lambda{AMEE::Connection.new(nil, 'username', 'password')}.should raise_error
    lambda{AMEE::Connection.new('server.example.com', nil, nil)}.should raise_error
    lambda{AMEE::Connection.new('server.example.com', 'username', nil)}.should raise_error
    lambda{AMEE::Connection.new('server.example.com', nil, 'password')}.should raise_error
    c = AMEE::Connection.new('server.example.com', 'username', 'password')
    c.should be_valid
  end

  it "has default timeout of 60 seconds" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    c = AMEE::Connection.new('server.example.com', 'username', 'password')
    c.timeout.should be(60)
  end

  it "can set timeout" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    c = AMEE::Connection.new('server.example.com', 'username', 'password')
    c.timeout = 30
    c.timeout.should be(30)
  end

  it "can set timeout on creation" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    c = AMEE::Connection.new('server.example.com', 'username', 'password', :timeout => 30)
    c.timeout.should be(30)
  end

end

describe AMEE::Connection, "with authentication" do

  it "should start out unauthenticated" do
    flexmock(Net::HTTP).new_instances.should_receive(:start => nil)
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.authenticated?.should be_false
  end

  it "detects the API version (1)" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => '0', :'[]' => 'dummy_auth_token_data'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.authenticate
    amee.authenticated?.should be_true
    amee.version.should == 1.0
  end

  it "detects the API version (2 - XML)" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => '<?xml version="1.0" encoding="UTF-8"?><Resources><SignInResource><Next>/auth</Next><User uid="DB2C6DA7EAA7"><Status>ACTIVE</Status><Type>STANDARD</Type><GroupNames><GroupName>amee</GroupName><GroupName>Standard</GroupName><GroupName>All</GroupName></GroupNames><ApiVersion>2.0</ApiVersion></User></SignInResource></Resources>', :'[]' => 'dummy_auth_token_data'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.authenticate
    amee.authenticated?.should be_true
    amee.version.should == 2.0
  end

  it "detects the API version (2 - JSON)" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => '{ "next" : "/auth","user" : { "apiVersion" : "2.0","groupNames" : [ "amee","Standard","All"],"status" : "ACTIVE","type" : "STANDARD","uid" : "DB2C6DA7EAA7"}}', :'[]' => 'dummy_auth_token_data'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.authenticate
    amee.authenticated?.should be_true
    amee.version.should == 2.0
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
    lambda{amee.get('/missing_url')}.should raise_error(AMEE::NotFound, "The URL was not found on the server.\nRequest: GET /missing_url")
  end

  it "should raise error if permission for operation is denied" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '403', :body => '{}'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    lambda {
      amee.get('/data')
    }.should raise_error(AMEE::PermissionDenied,"You do not have permission to perform the requested operation.
Request: GET /data
Response: {}")
  end

  it "should raise error if authentication succeeds, but permission for operation is denied" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '401', :body => ''),
                                               flexmock(:code => '200', :body => '', :'[]' => 'dummy_auth_token_data'),
                                               flexmock(:code => '403', :body => '{}'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    lambda {
      amee.get('/data')
    }.should raise_error(AMEE::PermissionDenied,"You do not have permission to perform the requested operation.
Request: GET /data
Response: {}")
    amee.authenticated?.should be_true
  end

  it "should raise error if unhandled errors occur in connection" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '500', :body => '{}'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    lambda {
      amee.get('/data')
    }.should raise_error(AMEE::UnknownError,"An error occurred while talking to AMEE: HTTP response code 500.
Request: GET /data
Response: {}")
  end

end

describe AMEE::Connection, "with retry enabled" do

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
      amee = AMEE::Connection.new('server.example.com', 'username', 'password', :retries => 2)
      lambda {
        amee.get('/data')
      }.should_not raise_error        
    end

    it "should retry #{e.name} the correct number of times and raise error on failure" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).and_raise(e.new).times(3)
        mock.should_receive(:finish => nil)
      end
      amee = AMEE::Connection.new('server.example.com', 'username', 'password', :retries => 2)
      lambda {
        amee.get('/data')
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
      amee = AMEE::Connection.new('server.example.com', 'username', 'password', :retries => 2)
      lambda {
        amee.get('/data')
      }.should_not raise_error        
    end

    it "should retry #{e} the correct number of times and raise error on failure" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).and_return(flexmock(:code => e, :body => '{}')).times(3)
        mock.should_receive(:finish => nil)
      end
      amee = AMEE::Connection.new('server.example.com', 'username', 'password', :retries => 2)
      lambda {
        amee.get('/data')
      }.should raise_error(AMEE::ConnectionFailed)
    end
  end  
  
end

describe AMEE::Connection, "with incorrect server name" do

  it "should raise a useful error" do
    flexmock(Net::HTTP).new_instances.should_receive(:start).and_raise(SocketError.new)
    amee = AMEE::Connection.new('badservername.example.com', 'username', 'password')
    lambda{
      amee.get('/')
    }.should raise_error(AMEE::ConnectionFailed, "Connection failed. Check server name or network connection.")
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
    lambda{amee.get('/data')}.should raise_error(AMEE::AuthFailed, "Authentication failed. Please check your username and password. (tried wrong,details)")
  end

end

describe AMEE::Connection, "with authentication , doing write-requests" do

  it "should be able to send post requests" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => ''))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.post('/profiles', :test => 1, :test2 => 2) do |response|
      response.should be_empty
    end
  end

  it "should be able to send put requests" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => ''))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.put('/profiles/ABC123', :test => 1, :test2 => 2) do |response|
      response.should be_empty
    end
  end

  it "should be able to send delete requests" do
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => ''))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new('server.example.com', 'username', 'password')
    amee.delete('/profiles/ABC123') do |response|
      response.should be_empty
    end
  end

end
