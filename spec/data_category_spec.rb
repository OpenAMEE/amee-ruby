require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::Category do
  
  it "should have common AMEE object properties" do
    x = AMEE::Data::Category.new
    x.is_a?(AMEE::Object).should be_true
  end
  
end
