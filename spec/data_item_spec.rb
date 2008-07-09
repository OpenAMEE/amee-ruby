require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::Item do

  before(:each) do
    @item = AMEE::Data::Item.new
  end
  
  it "should have common AMEE object properties" do
    @item.is_a?(AMEE::Object).should be_true
  end
  
  it "should have a path" do
    @item.should respond_to(:path)
  end

  it "should have a full path" do
    @item.should respond_to(:full_path)
  end

  it "should have a name" do
    @item.should respond_to(:name)
  end

  it "should have values" do
    @item.should respond_to(:values)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @item = AMEE::Data::Item.new(:uid => uid)
    @item.uid.should == uid
  end

  it "can be created with hash of data" do
    path = "/transport/plane/generic"
    name = "Generic"
    values = ["one", "two"]
    @item = AMEE::Data::Item.new(:path => path, :name => name, :values => values)
    @item.path.should == path
    @item.name.should == name
    @item.values.should == values
  end
  
end
