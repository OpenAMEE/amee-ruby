require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Connection do

  it "doesn't cache GET requests if caching is disabled" do
    $amee_request_cache = {}
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).once.and_return(flexmock(:code => '200', :body => 'get response 1'))
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => 'get response 2'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new("server.example.com", "username", "password", false, false)
    amee.get('/url1').should == "get response 1"
    $cache.should be_nil
  end

  it "caches GET requests" do
    $amee_request_cache = {}
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).once.and_return(flexmock(:code => '200', :body => 'get response 1'))
      mock.should_receive(:request).and_return(flexmock(:code => '200', :body => 'get response 2'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new("server.example.com", "username", "password", false, true)
    amee.get('/url1')
    $cache.size.should be(1)
    $cache["/url1"].should == "get response 1"
    amee.get('/url1').should == "get response 1"
    $cache.size.should be(1)
    $cache["/url1"].should == "get response 1"
  end

  it "clears cache on PUT requests" do
    $cache = {}
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).once.and_return(flexmock(:code => '200', :body => 'get response'))
      mock.should_receive(:request).once.and_return(flexmock(:code => '200', :body => 'put response'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new("server.example.com", "username", "password", false, true)
    amee.get('/url1').should == "get response"
    $cache.size.should be(1)
    amee.put('/url2').should == "put response"
    $cache.size.should be(0)
  end

  it "clears cache on POST requests" do
    $cache = {}
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).once.and_return(flexmock(:code => '200', :body => 'get response'))
      mock.should_receive(:request).once.and_return(flexmock(:code => '200', :body => 'post response'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new("server.example.com", "username", "password", false, true)
    amee.get('/url1').should == "get response"
    $cache.size.should be(1)
    amee.post('/url2').should == "post response"
    $cache.size.should be(0)
  end

  it "clears cache on DELETE requests" do
    $cache = {}
    flexmock(Net::HTTP).new_instances do |mock|
      mock.should_receive(:start => nil)
      mock.should_receive(:request).once.and_return(flexmock(:code => '200', :body => 'get response'))
      mock.should_receive(:request).once.and_return(flexmock(:code => '200', :body => 'delete response'))
      mock.should_receive(:finish => nil)
    end
    amee = AMEE::Connection.new("server.example.com", "username", "password", false, true)
    amee.get('/url1').should == "get response"
    $cache.size.should be(1)
    amee.delete('/url2').should == "delete response"
    $cache.size.should be(0)
  end

end
