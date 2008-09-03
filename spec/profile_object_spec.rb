require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Profile::Object do

  it "should have a full path under /profiles" do
    AMEE::Profile::Object.new.full_path.should == "/profiles"
  end

  it "can have a profile UID" do
    obj = AMEE::Profile::Object.new(:profile_uid => 'ABC123')
    obj.profile_uid.should == "ABC123"
  end

  it "should create correct path if profile UID is set" do
    obj = AMEE::Profile::Object.new(:profile_uid => 'ABC123')
    obj.full_path.should == "/profiles/ABC123"
  end

  it "can have a profile date" do
    obj = AMEE::Profile::Object.new(:profile_date => DateTime.new(2008,01))
    obj.profile_date.should == DateTime.new(2008,01)
  end

end