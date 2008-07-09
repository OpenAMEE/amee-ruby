require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::Category do
  
  before(:each) do
    @cat = AMEE::Data::Category.new    
  end
  
  it "should have common AMEE object properties" do
    @cat.is_a?(AMEE::Object).should be_true
  end
  
  it "should have children" do
    @cat.should respond_to(:children)
  end

  it "should have items" do
    @cat.should respond_to(:items)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @cat = AMEE::Data::Category.new(:uid => uid)
    @cat.uid.should == uid
  end

  it "can be created with hash of data" do
    children = ["one", "two"]
    items = ["three", "four"]
    @cat = AMEE::Data::Category.new(:children => children, :items => items)
    @cat.children.should == children
    @cat.items.should == items
  end
  
end