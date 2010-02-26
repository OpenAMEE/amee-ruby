require File.dirname(__FILE__) + '/spec_helper.rb'


MockResourceShortPath="/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
MockResourcePath="/data#{MockResourceShortPath}"
MockResourceShortUIDPath="/transport/plane/generic/AD63A83B4D41/127612FA4921"
MockResourceUIDPath="/data#{MockResourceShortUIDPath}"
MockResourceDataItemShortPath="/transport/plane/generic/AD63A83B4D41"
MockResourceDataItemPath="/data#{MockResourceDataItemShortPath}"

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
    @value = AMEE::Data::ItemValue.new(:uid => uid)
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
    connection.should_receive(:get).with(MockResourcePath).and_return(flexmock(:body => '<Resources><DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><Value>0.1</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource></Resources>'))
    @value = AMEE::Data::ItemValue.get(connection, MockResourcePath)
    @value.uid.should == "127612FA4921"
    @value.name.should == "kgCO2 Per Passenger Journey"
    @value.path.should ==MockResourceShortPath
    @value.full_path.should == MockResourcePath
    @value.created.should == DateTime.new(2007,8,1,9,00,41)
    @value.modified.should == DateTime.new(2007,8,1,9,00,41)
    @value.value.should == 0.1
    @value.type.should == "DECIMAL"
    @value.from_profile?.should be_false
    @value.from_data?.should be_true
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(MockResourcePath).and_return(flexmock(:body => '{"dataItem":{"uid":"AD63A83B4D41"},"itemValue":{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","value":"0.1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}}'))
    @value = AMEE::Data::ItemValue.get(connection, MockResourcePath)
    @value.uid.should == "127612FA4921"
    @value.name.should == "kgCO2 Per Passenger Journey"
    @value.path.should == MockResourceShortPath
    @value.full_path.should == MockResourcePath
    @value.created.should == DateTime.new(2007,8,1,9,00,41)
    @value.modified.should == DateTime.new(2007,8,1,9,00,41)
    @value.value.should == 0.1
    @value.type.should == "DECIMAL"
    #@value.from_profile?.should be_false # NOT SET IN JSON
    #@value.from_data?.should be_true # NOT SET IN JSON
  end

  it "should fail gracefully with incorrect XML data" do
    connection = flexmock "connection"
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:get).with("/data").and_return(flexmock(:body => xml))
    lambda{AMEE::Data::ItemValue.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValue from XML. Check that your URL is correct.\n#{xml}")
  end

  it "should fail gracefully when the return is an item value history" do
    connection = flexmock "connection"
    xml = '<Resources><DataItemValueResource><ItemValues>'+
          '<ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4922"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate></StartDate>0<Value>1</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/>'+
          '<ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4922"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate></StartDate>1<Value>2</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/>'+
          '</ItemValues></DataItemValueResource></Resources>'
    connection.should_receive(:get).with(MockResourcePath).and_return(flexmock(:body => xml))
    lambda{AMEE::Data::ItemValue.get(connection, MockResourcePath)}.should raise_error(AMEE::BadData, "Couldn't load DataItemValue from XML. This is an item value history.\n#{xml}")
  end

  it "should should handle this data" do
    connection = flexmock "connection"
    xml = "<DataItemValueResource><ItemValues><ItemValue uid='14E0F070EDD6'><Path>massCO2PerEnergy</Path><Name>Mass CO2 per Energy</Name><Value>0.1382909</Value><Unit>kg</Unit><PerUnit>kWh</PerUnit><StartDate>1970-01-01T01:00:00+01:00</StartDate><ItemValueDefinition uid='073CE1A98F4C'><Path>massCO2PerEnergy</Path><Name>Mass CO2 per Energy</Name><ValueDefinition modified='2007-07-27 09:30:44.0' uid='45433E48B39F' created='2007-07-27 09:30:44.0'><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid='5F5887BCF726'/></ValueDefinition><Unit>kg</Unit><PerUnit>kWh</PerUnit><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue></ItemValues><DataItem uid='9FFE9E794049'/><Path>/test/api/item_history_test/9FFE9E794049/massCO2PerEnergy</Path></DataItemValueResource>"
    connection.should_receive(:get).with(MockResourcePath).and_return(flexmock(:body => xml))
    lambda{AMEE::Data::ItemValue.get(connection, MockResourcePath)}.should_not raise_error
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    json = '{}'
    connection.should_receive(:get).with("/data").and_return(flexmock(:body => json))
    lambda{AMEE::Data::ItemValue.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValue from JSON. Check that your URL is correct.\n#{json}")
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_raise("unidentified error")
    lambda{AMEE::Data::ItemValue.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValue. Check that your URL is correct.")
  end

end

describe AMEE::Data::ItemValue, "after loading" do

  before(:each) do
    @path = MockResourcePath
    @connection = flexmock "connection"
    @connection.should_receive(:get).with(@path).and_return(flexmock(:body => '{"dataItem":{"uid":"AD63A83B4D41"},"itemValue":{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","value":"0.1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}}'))
    @val = AMEE::Data::ItemValue.get(@connection, "/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney")
  end

  it "can have value changed and saved back to server" do
    @connection.should_receive(:put).
      with(MockResourceUIDPath,
      :value => 42).and_return(flexmock(:body => ''))
    lambda {
      @val.value = 42
      @val.save!
    }.should_not raise_error
  end

  it "can have value and start date changed and saved back to server" do
    @connection.should_receive(:put).
      with(MockResourceUIDPath,
      :value => 42,:startDate=>Time.at(10).xmlschema).and_return(flexmock(:body => ''))
    lambda {
      @val.value = 42
      @val.start_date=Time.at(10)
      @val.save!
    }.should_not raise_error
  end

  it "can be deleted" do
    @connection.should_receive(:delete).
      with(MockResourceUIDPath).
      and_return(flexmock(:body => ''))
    lambda {
      @val.delete!
    }.should_not raise_error
  end

  it "can be deleted with no uid" do
    @connection.should_receive(:delete).
      with(MockResourcePath).
      and_return(flexmock(:body => ''))
    lambda {
      @val.uid=nil
      @val.delete!
    }.should_not raise_error
  end

  it "can be created" do
    @connection.should_receive(:post).
      with(MockResourceDataItemPath,
      :kgCO2PerPassengerJourney=>42,
      :startDate=>(AMEE::Epoch+3).xmlschema).
      and_return({'Location'=>'http://foo.com/'})
    @new=AMEE::Data::ItemValue.new(:value=>42,
      :start_date=>AMEE::Epoch+3,
      :connection=>@connection,
      :path=>MockResourceDataItemShortPath+"/kgCO2PerPassengerJourney")
    lambda {      
      @new.create!
    }.should_not raise_error
  end

end
