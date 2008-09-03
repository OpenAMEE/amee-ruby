require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::ItemValue do
  
  before(:each) do
    @value = AMEE::Data::ItemValue.new
  end
  
  it "should have common AMEE object properties" do
    @value.is_a?(AMEE::Data::Object).should be_true
  end
  
  it "should have a value" do
    @value.should respond_to(:value)
  end

  it "should have a type" do
    @value.should respond_to(:type)
  end

  it "can be from profile" do
    @value.should respond_to(:from_profile?)
  end

  it "can be from data" do
    @value.should respond_to(:from_data?)
  end
  
  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @value = AMEE::Data::Item.new(:uid => uid)
    @value.uid.should == uid
  end

  it "can be created with hash of data" do
    value = "test"
    type = "TEXT"
    from_profile = false
    from_data = true
    @value = AMEE::Data::ItemValue.new(:value => value, :type => type, :from_profile => from_profile, :from_data => from_data)
    @value.value.should == value
    @value.type.should == type
    @value.from_profile?.should be_false
    @value.from_data?.should be_true
  end

  it "should support DECIMAL data type" do
    @value = AMEE::Data::ItemValue.new(:value => "1.5", :type => "DECIMAL")
    @value.value.should == 1.5
  end

  it "should support TEXT data type" do
    @value = AMEE::Data::ItemValue.new(:value => "1.5", :type => "TEXT")
    @value.value.should == "1.5"
  end

  it "allows value to be changed after creation" do
    value = "test"
    type = "TEXT"
    from_profile = false
    from_data = true
    @value = AMEE::Data::ItemValue.new(:value => value, :type => type, :from_profile => from_profile, :from_data => from_data)
    @value.value.should == value
    value = 42
    @value.value = value
    @value.value.should == value
  end

end

describe AMEE::Data::ItemValue, "with an authenticated connection" do

  it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney").and_return('<Resources><DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><Value>0.1</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource></Resources>')
    @value = AMEE::Data::ItemValue.get(connection, "/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney")
    @value.uid.should == "127612FA4921"
    @value.name.should == "kgCO2 Per Passenger Journey"
    @value.path.should == "/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
    @value.full_path.should == "/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
    @value.created.should == DateTime.new(2007,8,1,9,00,41)
    @value.modified.should == DateTime.new(2007,8,1,9,00,41)
    @value.value.should == 0.1
    @value.type.should == "DECIMAL"
    @value.from_profile?.should be_false
    @value.from_data?.should be_true
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney").and_return('{"dataItem":{"uid":"AD63A83B4D41"},"itemValue":{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","value":"0.1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}}')
    @value = AMEE::Data::ItemValue.get(connection, "/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney")
    @value.uid.should == "127612FA4921"
    @value.name.should == "kgCO2 Per Passenger Journey"
    @value.path.should == "/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
    @value.full_path.should == "/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
    @value.created.should == DateTime.new(2007,8,1,9,00,41)
    @value.modified.should == DateTime.new(2007,8,1,9,00,41)
    @value.value.should == 0.1
    @value.type.should == "DECIMAL"
    #@value.from_profile?.should be_false # NOT SET IN JSON
    #@value.from_data?.should be_true # NOT SET IN JSON
  end

  it "should fail gracefully with incorrect XML data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>')
    lambda{AMEE::Data::ItemValue.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValue from XML. Check that your URL is correct.")
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('{}')
    lambda{AMEE::Data::ItemValue.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValue from JSON. Check that your URL is correct.")
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_raise("unidentified error")
    lambda{AMEE::Data::ItemValue.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValue. Check that your URL is correct.")
  end

end

describe AMEE::Data::ItemValue, "after loading" do

  before(:each) do
    @path = "/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
    @connection = flexmock "connection"
    @connection.should_receive(:get).with(@path).and_return('{"dataItem":{"uid":"AD63A83B4D41"},"itemValue":{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","value":"0.1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}}')
    @val = AMEE::Data::ItemValue.get(@connection, "/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney")
  end

  it "can have value changed and saved back to server" do
    @connection.should_receive(:put).with("/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney", :value => 42).and_return('')
    lambda {
      @val.value = 42
      @val.save!
    }.should_not raise_error
  end

end
