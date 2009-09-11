require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Admin::User do

  before(:each) do
    @user = AMEE::Admin::User.new
  end
  
  it "should have common AMEE object properties" do
    @user.is_a?(AMEE::Object).should be_true
  end

  it "should have a login" do
    @user.should respond_to(:login)
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
      :login => "test_login",
      :name => "test_name",
      :email => "test_email",
      :api_version => "2.0"
    }
    @user = AMEE::Admin::User.new(data)
    @user.name.should == data[:name]
    @user.login.should == data[:login]
    @user.email.should == data[:email]
    @user.api_version.should == data[:api_version].to_f
  end
  
end
