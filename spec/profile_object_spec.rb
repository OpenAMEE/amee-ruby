require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::ProfileObject do

  it "should have a full path under /profiles" do
    AMEE::ProfileObject.new.full_path.should == "/profiles"
  end

end