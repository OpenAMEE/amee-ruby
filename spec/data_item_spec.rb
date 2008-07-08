require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::Item do
  
  it "should have common AMEE object properties" do
    x = AMEE::Data::Item.new
    x.is_a?(AMEE::Object).should be_true
  end
  
end
