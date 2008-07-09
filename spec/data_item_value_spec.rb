require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::ItemValue do
  
  before(:each) do
    @value = AMEE::Data::ItemValue.new
  end
  
  it "should have common AMEE object properties" do
    @value.is_a?(AMEE::Object).should be_true
  end
  
  it "should a value" do
    @value.should respond_to(:value)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @value = AMEE::Data::Item.new(:uid => uid)
    @value.uid.should == uid
  end

  it "can be created with hash of data" do
    value = "0"
    @value = AMEE::Data::ItemValue.new(:value => value)
    @value.value.should == value
  end

end
