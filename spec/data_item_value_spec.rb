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

describe AMEE::Data::ItemValue, "with an authenticated connection" do

  it "should parse correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney").and_return('<Resources><DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><Value>0</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource></Resources>')
    @value = AMEE::Data::ItemValue.get(connection, "/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney")
    @value.uid.should == "127612FA4921"
    @value.name.should == "kgCO2 Per Passenger Journey"
    @value.path.should == "/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
    @value.created.should == DateTime.new(2007,8,1,9,00,41)
    @value.modified.should == DateTime.new(2007,8,1,9,00,41)
    @value.value.should == "0"
  end

end