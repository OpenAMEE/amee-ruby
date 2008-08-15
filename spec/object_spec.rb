require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Object do

  it "can be created from hash of data" do
    data = {}
    data[:uid] = @uid = 'AB69E4AE213B'
    data[:created] = @creation_time = Time.now - 10000
    data[:modified] = @modification_time = Time.now - 1000
    data[:path] = @path = "/transport/plane/generic/ABCD1234"
    data[:name] = @name = "kgPerPassengerJourney"
    o = AMEE::Object.new(data)
    o.uid.should == @uid
    o.created.should == @creation_time
    o.modified.should == @modification_time
    o.path.should == @path
    o.name.should == @name
  end
  
  it "should have a uid" do
    AMEE::Object.new.should respond_to(:uid)
  end

  it "should have a created time" do
    AMEE::Object.new.should respond_to(:created)
  end

  it "should have a modified time" do
    AMEE::Object.new.should respond_to(:modified)
  end

  it "should have a name" do
    AMEE::Object.new.should respond_to(:name)
  end

  it "can be created without data" do
    o = AMEE::Object.new
    o.uid.should be_nil
    o.created.should == o.modified
    o.path.should be_nil
    o.name.should be_nil
  end

end