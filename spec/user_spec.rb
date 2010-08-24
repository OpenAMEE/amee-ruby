require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Admin::User do

  before(:each) do
    @user = AMEE::Admin::User.new
  end
  
  it "should have common AMEE object properties" do
    @user.is_a?(AMEE::Object).should be_true
  end

  it "should have a username" do
    @user.should respond_to(:username)
  end

  it "should have an email" do
    @user.should respond_to(:email)
  end

  it "should have a name" do
    @user.should respond_to(:name)
  end

  it "should have an api version" do
    @user.should respond_to(:api_version)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @user = AMEE::Admin::User.new(:uid => uid)
    @user.uid.should == uid
  end

  it "can be created with hash of data" do
    data = {
      :username => "test_login",
      :name => "test_name",
      :email => "test_email",
      :api_version => "2.0"
    }
    @user = AMEE::Admin::User.new(data)
    @user.name.should == data[:name]
    @user.username.should == data[:username]
    @user.email.should == data[:email]
    @user.api_version.should == data[:api_version].to_f
  end
  
end

describe AMEE::Admin::User, "with an authenticated connection" do

  before :all do
    @env = "5F5887BCF726"
    @options = {
      :username => "_rubytest",
      :name => "Test User created by Ruby Gem",
      :email => "ruby@amee.cc",
      :apiVersion => 2.0,
      :password => "test_pw"
    }
    @users_path = "/environments/#{@env}/users"
    @path = "/environments/#{@env}/users/_rubytest"
    @new_options = {
      :username => "_rubytest_changed",
      :name => "Test User created by Ruby Gem, then changed",
      :email => "ruby_changed@amee.cc",
      :APIVersion => 1.0
    }
    @changed_path = "/environments/#{@env}/users/_rubytest_changed"
  end

  it "can create a new user" do
    connection = flexmock "connection"
    connection.should_receive(:post).with(@users_path, @options).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><UsersResource><User created="Fri Sep 11 16:41:16 BST 2009" modified="Fri Sep 11 16:41:16 BST 2009" uid="65ED20D9C5EF"><Status>ACTIVE</Status><Type>STANDARD</Type><GroupNames/><ApiVersion>2.0</ApiVersion><Locale>en_GB</Locale><Name>Test User created by Ruby Gem</Name><Username>_rubytest</Username><Email>ruby@amee.cc</Email><Environment uid="5F5887BCF726"/></User></UsersResource></Resources>'))
    @user = AMEE::Admin::User.create(connection, @env, @options)
  end

  it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(@path, {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><UserResource><Environment uid="5F5887BCF726"/><User created="2009-09-11 16:41:16.0" modified="2009-09-11 16:41:16.0" uid="65ED20D9C5EF"><Status>ACTIVE</Status><Type>STANDARD</Type><GroupNames/><ApiVersion>2.0</ApiVersion><Locale>en_GB</Locale><Name>Test User created by Ruby Gem</Name><Username>_rubytest</Username><Email>ruby@amee.cc</Email><Environment uid="5F5887BCF726"/></User></UserResource></Resources>'))
    @data = AMEE::Admin::User.get(connection, @path)
    @data.uid.should == "65ED20D9C5EF"
    @data.created.should == DateTime.new(2009,9,11,16,41,16)
    @data.modified.should == DateTime.new(2009,9,11,16,41,16)
    @data.username.should == @options[:username]
    @data.name.should == @options[:name]
    @data.email.should == @options[:email]
    @data.api_version.should be_close(@options[:apiVersion], 1e-9)
    @data.status.should == "ACTIVE"
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(@path, {}).and_return(flexmock(:body => '{"user":{"apiVersion":"2.0","uid":"2C4D789B1D46","username":"_rubytest","environment":{"uid":"5F5887BCF726"},"created":"Fri Sep 11 16:29:42 BST 2009","email":"ruby@amee.cc","status":"ACTIVE","name":"Test User created by Ruby Gem","locale":"en_GB","groupNames":[],"type":"STANDARD","modified":"Fri Sep 11 16:29:42 BST 2009"}}'))
    @data = AMEE::Admin::User.get(connection, @path)
    @data.uid.should == "2C4D789B1D46"
    @data.created.should == DateTime.new(2009,9,11,15,29,42)
    @data.modified.should == DateTime.new(2009,9,11,15,29,42)
    @data.username.should == @options[:username]
    @data.name.should == @options[:name]
    @data.email.should == @options[:email]
    @data.api_version.should be_close(@options[:apiVersion], 1e-9)
    @data.status.should == "ACTIVE"
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:get).with(@path, {}).and_return(flexmock(:body => xml))
    lambda{AMEE::Admin::User.get(connection, @path)}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    json = '{}'
    connection.should_receive(:get).with(@path, {}).and_return(flexmock(:body => json))
    lambda{AMEE::Admin::User.get(connection, @path)}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(@path, {}).and_raise("unidentified error")
    lambda{AMEE::Admin::User.get(connection, @path)}.should raise_error(AMEE::BadData)
  end

  it "can update an existing user" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(@path, {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><UserResource><Environment uid="5F5887BCF726"/><User created="2009-09-11 16:41:16.0" modified="2009-09-11 16:41:16.0" uid="65ED20D9C5EF"><Status>ACTIVE</Status><Type>STANDARD</Type><GroupNames/><ApiVersion>2.0</ApiVersion><Locale>en_GB</Locale><Name>Test User created by Ruby Gem</Name><Username>_rubytest</Username><Email>ruby@amee.cc</Email><Environment uid="5F5887BCF726"/></User></UserResource></Resources>'))
    @data = AMEE::Admin::User.get(connection, @path)
    connection.should_receive(:put).with(@data.full_path, @new_options).and_return(flexmock(:code => 200, :body => ""))
    connection.should_receive(:get).with(@data.full_path, {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><UserResource><Environment uid="5F5887BCF726"/><User created="2009-09-11 16:41:16.0" modified="2009-09-11 16:55:14.0" uid="65ED20D9C5EF"><Status>ACTIVE</Status><Type>STANDARD</Type><GroupNames/><ApiVersion>1.0</ApiVersion><Locale>en_GB</Locale><Name>Test User created by Ruby Gem, then changed</Name><Username>_rubytest_changed</Username><Email>ruby_changed@amee.cc</Email><Environment uid="5F5887BCF726"/></User></UserResource></Resources>'))
    @new_data = @data.update(@new_options)
    @new_data.created.should_not == @new_data.modified.should
    @new_data.username.should == @new_options[:username]
    @new_data.name.should == @new_options[:name]
    @new_data.email.should == @new_options[:email]
    @new_data.api_version.should be_close(@new_options[:APIVersion],1e-9)
  end

  it "can delete an existing user" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(@changed_path, {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><UserResource><Environment uid="5F5887BCF726"/><User created="2009-09-11 16:41:16.0" modified="2009-09-11 16:55:14.0" uid="65ED20D9C5EF"><Status>ACTIVE</Status><Type>STANDARD</Type><GroupNames/><ApiVersion>2.0</ApiVersion><Locale>en_GB</Locale><Name>Test User created by Ruby Gem, then changed</Name><Username>_rubytest</Username><Email>ruby_changed@amee.cc</Email><Environment uid="5F5887BCF726"/></User></UserResource></Resources>'))
    @data = AMEE::Admin::User.get(connection, @changed_path)
    connection.should_receive(:delete).with(@data.full_path).and_return(flexmock(:code => 200, :body => ""))
    lambda{@new_data = @data.delete}.should_not raise_error
  end

end