require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Profile::ItemValue do
  
  before(:each) do
    @value = AMEE::Profile::ItemValue.new
  end
  
  it "should have common AMEE object properties" do
    @value.is_a?(AMEE::Profile::Object).should be_true
  end
  
  it "should have a value" do
    @value.should respond_to(:value)
  end

  it "should have a type" do
    @value.should respond_to(:type)
  end

  it "should initialize AMEE::Object Profile on creation" do
    uid = 'ABCD1234'
    @value = AMEE::Profile::ItemValue.new(:uid => uid)
    @value.uid.should == uid
  end

  it "can be created with hash of Profile" do
    value = "test"
    type = "STRING"
    @value = AMEE::Profile::ItemValue.new(:value => value, :type => type)
    @value.value.should == value
    @value.type.should == type
  end

  it "should support DECIMAL data type" do
    @value = AMEE::Profile::ItemValue.new(:value => "1.5", :type => "DECIMAL")
    @value.value.should == 1.5
  end

  it "should support TEXT data type" do
    @value = AMEE::Profile::ItemValue.new(:value => "1.5", :type => "TEXT")
    @value.value.should == "1.5"
  end

  it "allows value to be changed after creation" do
    value = "test"
    type = "TEXT"
    @value = AMEE::Profile::ItemValue.new(:value => value, :type => type)
    @value.value.should == value
    value = "hello"
    @value.value = value
    @value.value.should == value
  end

end

describe AMEE::Profile::ItemValue, "with an authenticated connection" do

  it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileItemValueResource><ItemValue Created="2009-03-24 11:15:13.0" Modified="2009-03-24 11:15:20.0" uid="BA4428721987"><Path>kWhPerMonth</Path><Name>kWh Per Month</Name><Value>10</Value><ItemValueDefinition uid="4DF458FD0E4D"><Path>kWhPerMonth</Path><Name>kWh Per Month</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="26A5C97D3728"><Name>kWh</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><ProfileItem uid="B099A221106E"/></ItemValue><Path>/home/energy/quantity/B099A221106E/kWhPerMonth</Path><Profile uid="AEC30FB9BCB9"/></ProfileItemValueResource></Resources>'))
    @value = AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")
    @value.uid.should == "BA4428721987"
    @value.name.should == "kWh Per Month"
    @value.path.should == "/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth"
    @value.full_path.should == "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth"
    @value.created.should == DateTime.new(2009,3,24,11,15,13)
    @value.modified.should == DateTime.new(2009,3,24,11,15,20)
    @value.value.should == 10
    @value.type.should == "DECIMAL"
    @value.from_profile?.should be_true
    @value.from_data?.should be_false
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_return(flexmock(:body => '{"path":"/home/energy/quantity/B099A221106E/kWhPerMonth","profile":{"uid":"AEC30FB9BCB9"},"itemValue":{"item":{"uid":"B099A221106E"},"modified":"2009-03-24 11:15:20.0","created":"2009-03-24 11:15:13.0","value":"10","uid":"BA4428721987","path":"kWhPerMonth","name":"kWh Per Month","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"26A5C97D3728","name":"kWh"},"uid":"4DF458FD0E4D","path":"kWhPerMonth","name":"kWh Per Month"}}}'))
    @value = AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")
    @value.uid.should == "BA4428721987"
    @value.name.should == "kWh Per Month"
    @value.path.should == "/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth"
    @value.full_path.should == "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth"
    @value.created.should == DateTime.new(2009,3,24,11,15,13)
    @value.modified.should == DateTime.new(2009,3,24,11,15,20)
    @value.value.should == 10
    @value.type.should == "DECIMAL"
    #@value.from_profile?.should be_false # NOT SET IN JSON
    #@value.from_data?.should be_true # NOT SET IN JSON
  end

  it "should fail gracefully with incorrect XML data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'))
    lambda{AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")}.should raise_error(AMEE::BadData, "Couldn't load ProfileItemValue from XML. Check that your URL is correct.")
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_return(flexmock(:body => '{}'))
    lambda{AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")}.should raise_error(AMEE::BadData, "Couldn't load ProfileItemValue from JSON. Check that your URL is correct.")
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_raise("unidentified error")
    lambda{AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")}.should raise_error(AMEE::BadData, "Couldn't load ProfileItemValue. Check that your URL is correct.")
  end

end

#describe AMEE::Profile::ItemValue, "after loading" do
#
#  before(:each) do
#    @path = "/Profile/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
#    @connection = flexmock "connection"
#    @connection.should_receive(:get).with(@path).and_return(flexmock(:body => '{"ProfileItem":{"uid":"AD63A83B4D41"},"itemValue":{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","value":"0.1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}}'))
#    @val = AMEE::Profile::ItemValue.get(@connection, "/Profile/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney")
#  end
#
#  it "can have value changed and saved back to server" do
#    @connection.should_receive(:put).with("/Profile/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney", :value => 42).and_return(flexmock(:body => ''))
#    lambda {
#      @val.value = 42
#      @val.save!
#    }.should_not raise_error
#  end
#
#end
