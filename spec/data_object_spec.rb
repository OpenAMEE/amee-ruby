require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::DataObject do

  it "should have a full path under /data" do
    AMEE::DataObject.new.full_path.should == "/data"
  end

end