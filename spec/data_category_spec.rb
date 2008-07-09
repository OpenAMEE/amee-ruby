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

  it "should have a full path" do
    @cat.should respond_to(:full_path)
  end

  it "should have a name" do
    @cat.should respond_to(:name)
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
    path = ""
    name = "Root"
    children = ["one", "two"]
    items = ["three", "four"]
    @cat = AMEE::Data::Category.new(:path => path, :name => name, :children => children, :items => items)
    @cat.path.should == path
    @cat.name.should == name
    @cat.children.should == children
    @cat.items.should == items
  end
  
end