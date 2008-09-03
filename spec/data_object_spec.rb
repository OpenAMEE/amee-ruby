require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::Object do

  it "should have a full path under /data" do
    AMEE::Data::Object.new.full_path.should == "/data"
  end

end