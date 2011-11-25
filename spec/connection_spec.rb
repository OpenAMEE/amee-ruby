# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'

describe AMEE::Connection do

  it "requires server name, username, and password" do

    lambda{AMEE::Connection.new(nil, nil, nil)}.should raise_error
    lambda{AMEE::Connection.new(nil, 'username', nil)}.should raise_error
    lambda{AMEE::Connection.new(nil, nil, 'password')}.should raise_error
    lambda{AMEE::Connection.new(nil, 'username', 'password')}.should raise_error
    lambda{AMEE::Connection.new('stage.amee.com', nil, nil)}.should raise_error
    lambda{AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, nil)}.should raise_error
    lambda{AMEE::Connection.new('stage.amee.com', nil, 'password')}.should raise_error
    c = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
    c.should be_valid
  end

  it "has default timeout of 60 seconds" do

    c = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
    c.timeout.should be(60)
  end

  it "can set timeout" do
    c = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
    c.timeout = 30
    c.timeout.should be(30)
  end

  it "can set timeout on creation" do
    c = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD, :timeout => 30)
    c.timeout.should be(30)
  end

end

describe AMEE::Connection, "with authentication" do

  describe "using a version 1 api key" do
    use_vcr_cassette "using a v1 key", :record => :new_episodes
    it "detects the API version (1)" do
      amee = AMEE::Connection.new('stage.amee.com', AMEE_V1_API_KEY, AMEE_V1_PASSWORD)
      amee.authenticate
      amee.authenticated?.should be_true
      amee.version.should == 1.0
    end
  end

  describe "using a version 2 api key" do

  use_vcr_cassette
  it "should start out unauthenticated" do
    amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
    amee.authenticated?.should be_false
  end


  it "detects the API version (2 - XML) normally" do
    amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
    amee.authenticate
    amee.authenticated?.should be_true
    amee.version.should == 2.0
  end

  it "detects the API version (2 - JSON)" do
    amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
    amee.authenticate
    amee.authenticated?.should be_true
    amee.version.should == 2.0
  end

  end

  describe "hitting_private_urls" do
    use_vcr_cassette

    it "should be able to get private URLs" do
      amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
      amee.get('/data') do |response|
        response.should_not be_empty
      end
      amee.authenticated?.should be_true
    end
  end

  describe "handling 404s" do
    use_vcr_cassette
    it "should handle 404s gracefully" do
      amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
      lambda{amee.get('/missing_url')}.should raise_error(AMEE::NotFound, "The URL was not found on the server.\nRequest: GET /missing_url")
    end
  end

  describe "raising errors if permission denied" do
    use_vcr_cassette

    it "should raise error if permission for operation is denied" do
      amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
      lambda {
        amee.get('/data/lca/ecoinvent')
      }.should raise_error(AMEE::PermissionDenied)
    end
  end
  describe "raising unhandled errors" do
    it "should raise error if unhandled errors occur in connection" do
      pending # not sure how best to fake breaking this
      # flexmock(Net::HTTP).new_instances do |mock|
      #   mock.should_receive(:start => nil)
      #   mock.should_receive(:request).and_return(flexmock(:code => '500', :body => '{}'))
      #   mock.should_receive(:finish => nil)
      # end
      amee = AMEE::Connection.new('stage.amee.com', 'wrong', 'wrong')
      lambda {
        amee.get('/something_that_will_cause_a_500')
      }.should raise_error(AMEE::UnknownError,"An error occurred while talking to AMEE: HTTP response code 500.
  Request: GET /data
  Response: {}")
    end
  end

end

describe AMEE::Connection, "with retry enabled" do
  use_vcr_cassette
  [
    Timeout::Error,
    Errno::EINVAL,
    Errno::ECONNRESET,
    EOFError,
  ].each do |e|

    it "should retry after #{e.name} the correct number of times" do
      pending
      # binding.pry
      # Webmock.stub_request(:any, 'stage.amee.com').to_timeout.then.
      # to_timeout.then
      # to_return({:code => '200', :body => '{}'})
      flexmock(Typhoeus::Response).new_instances do |mock|

        # queue it on
        # call run
        # mock the request.response after calling run, to return the timeout
        # make sure we mock out the authenticated method on the connection object

        mock.should_receive(:code).and_raise(e.new).twice
        mock.should_receive(:request).and_return(flexmock(:code => '200', :body => '{}')).once
        mock.should_receive(:finish => nil)
      end
      amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD, :retries => 2)
      lambda {
        amee.get('/data')
      }.should_not raise_error
    end

    it "should retry #{e.name} the correct number of times and raise error on failure" do
      pending
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).and_raise(e.new).times(3)
        mock.should_receive(:finish => nil)
      end
      amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD, :retries => 2)
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
      pending
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).and_return(flexmock(:code => e, :body => '{}')).twice
        # 
        mock.should_receive(:request).and_return(flexmock(:code => '200', :body => '{}')).once
        mock.should_receive(:finish => nil)
      end
      amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD, :retries => 2)
      lambda {
        amee.get('/data')
      }.should_not raise_error
    end

    it "should retry #{e} the correct number of times and raise error on failure" do
      pending # these look like they might need to be mocked out anyway
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).and_return(flexmock(:code => e, :body => '{}')).times(3)
        mock.should_receive(:finish => nil)
      end
      amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD, :retries => 2)
      lambda {
        amee.get('/data')
      }.should raise_error(AMEE::ConnectionFailed)
    end
  end

end

describe AMEE::Connection, "with incorrect server name" do

  use_vcr_cassette
  it "should raise a useful error" do
    amee = AMEE::Connection.new('badservername.example.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
    lambda{
      amee.get('/')
    }.should raise_error(AMEE::ConnectionFailed, "Connection failed. Check server name or network connection.")
  end

end

describe AMEE::Connection, "with bad authentication information" do

  describe "hitting a private url" do
    use_vcr_cassette
    it "should get an authentication failure" do
      amee = AMEE::Connection.new('stage.amee.com', 'wrong', 'details')
      lambda{
        amee.get('/data')
      }.should raise_error(AMEE::AuthFailed, "Authentication failed. Please check your username and password. (tried wrong,details)")
    end
  end

  # according to the docs, public urls should not be accessible without
  # an api key either
  # http://www.amee.com/developer/docs/apc.php#auth-reference
  describe "hitting a public url" do
    use_vcr_cassette
    it "should not be capable of making requests for public URLs" do
      amee = AMEE::Connection.new('stage.amee.com', 'wrong', 'details')
      # binding.pry
      lambda{
        amee.get('/')
      }.should raise_error
    end
  end



end

describe AMEE::Connection, "with authentication , doing write-requests" do
  use_vcr_cassette
  it "should be able to send post requests" do
    amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
    amee.post('/profiles', {:profile => true}) do |response|
      response.code.should be_200
    end
  end

  describe "working with an existing profile" do

    describe "sending updates to existing items" do
      use_vcr_cassette
      it "should be possible" do

        amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)

        profile_creation_post = amee.post('/profiles', {:profile => true})
        profile = JSON.parse(profile_creation_post.body)['profile']['uid']

        # fetch the new_item type uid to create
        new_item_drill = amee.get('/data/test/apitests/drill')
        new_item_uid = JSON.parse(new_item_drill.body)['choices']['choices'].first['value']
        # create a new item
        new_profile = amee.post("/profiles/#{profile}/test/apitests", :dataItemUid => new_item_uid)
        # update the new item
        path = new_profile.headers_hash['location'].gsub('http://stage.amee.com', '')
        amee.put(path, :dataItemUid => new_item_uid) do |response|
          response.should be_empty
        end
      end
    end

    describe "deleting existing items" do
      use_vcr_cassette
      it "should also be possible" do

        amee = AMEE::Connection.new('stage.amee.com', AMEE_V2_API_KEY, AMEE_V2_PASSWORD)
        profile_creation_post = amee.post('/profiles', {:profile => true})
        profile = JSON.parse(profile_creation_post.body)['profile']['uid']

        # fetch the new_item type uid to create
        new_item_drill = amee.get('/data/test/apitests/drill')
        new_item_uid = JSON.parse(new_item_drill.body)['choices']['choices'].first['value']
        # create a new item
        new_profile = amee.post("/profiles/#{profile}/test/apitests", :dataItemUid => new_item_uid)
        # delete the new item
        path = new_profile.headers_hash['location'].gsub('http://stage.amee.com', '')
        amee.delete(path) do |response|
          response.should be_empty
        end
      end
    end


  end

end
