require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Profile::Object do

  it "should have a full path under /profiles" do
    AMEE::Profile::Object.new.full_path.should == "/profiles"
  end

end