require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Object do

  it "can be created from hash of data" do
    data = {}
    data[:uid] = @uid = 'AB69E4AE213B'
    data[:created] = @creation_time = Time.now - 10000
    data[:modified] = @modification_time = Time.now - 1000
    o = AMEE::Object.new(data)
    o.uid.should == @uid
    o.created.should == @creation_time
    o.modified.should == @modification_time
  end
  
  it "can be created without data" do
    o = AMEE::Object.new
    o.uid.should be_nil
    o.created.should == o.modified
  end

  it "can set uid" do
    o = AMEE::Object.new
    o.uid.should be_nil
    @string = "TEST"
    o.uid = @string
    o.uid.should == @string
  end

end