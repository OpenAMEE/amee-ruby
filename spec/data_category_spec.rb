require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::Category do
  
  before(:each) do
    @cat = AMEE::Data::Category.new    
  end
  
  it "should have common AMEE object properties" do
    @cat.is_a?(AMEE::Object).should be_true
  end
  
  it "should have a path" do
    @cat.should respond_to(:path)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @cat = AMEE::Data::Category.new(:uid => uid)
    @cat.uid.should == uid
  end

  it "can be created with data" do
    path = "/data"
    @cat = AMEE::Data::Category.new(:path => path)
    @cat.path.should == path
  end
  
end