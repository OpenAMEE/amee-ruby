require File.dirname(__FILE__) + '/spec_helper.rb'

TestSeriesOne=[[Time.at(0),1],[Time.at(1),2],[Time.at(3),4]]
TestSeriesTwo=[[Time.at(0),2],[Time.at(1),6],[Time.at(5),7],[Time.at(9),11]]

MockResourcePath="/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
MockDataItemPath="/data/transport/plane/generic/AD63A83B4D41"
MockResourceXML='<Resources><ItemValues>'+
          '<DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+Time.at(0).xmlschema+'</StartDate><Value>1</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource>'+
          '<DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4922"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+Time.at(1).xmlschema+'</StartDate><Value>2</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource>'+
          '<DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4923"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+Time.at(3).xmlschema+'</StartDate><Value>4</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource>'+
          '</ItemValues></Resources>'
MockResourceJSON='{"dataItem":{"uid":"AD63A83B4D41"},"itemValues":['+
' {"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+Time.at(0).xmlschema+'","value":"1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+Time.at(1).xmlschema+'","value":"2","uid":"127612FA4922","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+Time.at(3).xmlschema+'","value":"4","uid":"127612FA4923","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
']}'
MockResourceXMLTwo='<Resources><ItemValues>'+
          '<DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+Time.at(0).xmlschema+'</StartDate><Value>1</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource>'+
          '<DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4922"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+Time.at(1).xmlschema+'</StartDate><Value>6</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource>'+
          '<DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4924"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+Time.at(5).xmlschema+'</StartDate><Value>7</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource>'+
          '<DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4925"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+Time.at(9).xmlschema+'</StartDate><Value>11</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource>'+
          '</ItemValues></Resources>'
MockResourceJSONTwo='{"dataItem":{"uid":"AD63A83B4D41"},"itemValues":['+
' {"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+Time.at(0).xmlschema+'","value":"1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+Time.at(1).xmlschema+'","value":"6","uid":"127612FA4922","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+Time.at(5).xmlschema+'","value":"7","uid":"127612FA4924","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+Time.at(9).xmlschema+'","value":"11","uid":"127612FA4925","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
']}'
describe AMEE::Data::ItemValueHistory do
  
  before(:each) do
    @history = AMEE::Data::ItemValueHistory.new
  end
  
  it "should NOT have common AMEE object properties" do
    # we can't be an AMEE object, since we have a set of UIDs, not one UID
    @history.is_a?(AMEE::Data::Object).should be_false
  end
 
  it "should have an array of ItemValue objects" do
    @history.should respond_to(:values)
  end

  it "should be able to return a time series" do
    @history.should respond_to(:series)
  end

  it "should have a type" do
    @history.should respond_to(:type)
  end

  it "can be created with a type, and a time-value pairs array" do
    series=TestSeriesOne
    type = "TEXT"
    @history = AMEE::Data::ItemValueHistory.new(:series => series, :type => type)
    @history.series.should == series
    @history.type.should == type
    @history.values[0].is_a?(AMEE::Data::ItemValue).should be_true
    @history.values[0].value.should == 1
    @history.values[0].start_date.should == Time.at(0)
  end

  it "can be created by pushing to the array of item values" do
    series=TestSeriesOne
    type = "TEXT"
    @history = AMEE::Data::ItemValueHistory.new(:type=>type)
    @history.series.should == []
    @history.type.should == type
    @fstvalue = AMEE::Data::ItemValue.new(:type=>type,:value=>1,:start_date=>Time.at(0))
    @sndvalue = AMEE::Data::ItemValue.new(:type=>type,:value=>2,:start_date=>Time.at(1))
    @trdvalue = AMEE::Data::ItemValue.new(:type=>type,:value=>4,:start_date=>Time.at(3))
    @history.values.push @fstvalue
    @history.values.push @sndvalue
    @history.values.push @trdvalue
    @history.values[0].is_a?(AMEE::Data::ItemValue).should be_true
    @history.values[0].value.should == 1
    @history.values[0].start_date.should == Time.at(0)
    @history.series.should == series
  end

  it "should support DECIMAL data type" do
    @history = AMEE::Data::ItemValueHistory.new(:series => TestSeriesOne, :type => "DECIMAL")
    @history.series.should == TestSeriesOne
  end

  it "should support TEXT data type" do
    @history = AMEE::Data::ItemValueHistory.new(:series => TestSeriesOne, :type => "TEXT")
    @history.series.should == TestSeriesOne
  end

  it "allows value to be changed after creation" do
    series=TestSeriesOne
    type = "TEXT"
    @history = AMEE::Data::ItemValueHistory.new(:series => series, :type => type)
    @history.series.should == series
    series = TestSeriesTwo
    @history.series = series
    @history.series.should == series
    @history.values[1].value.should == 6
  end

  it "allows item value to be found by time" do
    series=TestSeriesTwo
    type = "TEXT"
    @history = AMEE::Data::ItemValueHistory.new(:series => series, :type => type)
    @value=@history.value_at(Time.at(5))
    @value.value.should == 7
    lambda {
      @history.value_at(Time.at(6))
    }.should raise_error
  end

end

describe AMEE::Data::ItemValueHistory, "with an authenticated connection" do

  it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(MockResourcePath).
      and_return(flexmock(:body => MockResourceXML))
    @history = AMEE::Data::ItemValueHistory.get(connection, MockResourcePath)
    @history.series.should == TestSeriesOne
    @fstvalue=@history.values[0]
    @sndvalue=@history.values[1]
    @fstvalue.uid.should == "127612FA4921"
    @sndvalue.uid.should == "127612FA4922"
    @fstvalue.name.should == "kgCO2 Per Passenger Journey"
    @fstvalue.full_path.should == MockResourcePath
    @fstvalue.created.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.modified.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.type.should == "DECIMAL"
    @history.series.should == TestSeriesOne
    @history.type.should == "DECIMAL"
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(MockResourcePath).and_return(flexmock(:body => MockResourceJSON))
    @history = AMEE::Data::ItemValueHistory.get(connection, MockResourcePath)
    @fstvalue=@history.values[0]
    @sndvalue=@history.values[1]
    @fstvalue.uid.should == "127612FA4921"
    @sndvalue.uid.should == "127612FA4922"
    @fstvalue.name.should == "kgCO2 Per Passenger Journey"
    @fstvalue.full_path.should == MockResourcePath
    @fstvalue.created.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.modified.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.type.should == "DECIMAL"
    @history.series.should == TestSeriesOne
    @history.type.should == "DECIMAL"
  end

  it "should fail gracefully with incorrect XML data" do
    connection = flexmock "connection"
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:get).with("/data").and_return(flexmock(:body => xml))
    lambda{AMEE::Data::ItemValue.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValue from XML. Check that your URL is correct.\n#{xml}")
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
    @connection.should_receive(:get).with(@path).and_return(flexmock(:body => MockResourceJSON))
    @val = AMEE::Data::ItemValueHistory.get(@connection, "")
  end

  it "can have series changed and saved back to server" do
    @connection.should_receive(:put).with(MockDataItemPath+"/127612FA4921", :value => 2, :start_date => Time.at(0)).and_return(flexmock(:body => ''))
    @connection.should_receive(:put).with(MockDataItemPath+"/127612FA4922", :value => 6, :start_date => Time.at(1)).and_return(flexmock(:body => ''))
    @connection.should_receive(:delete).with(MockDataItemPath+"/127612FA4923").and_return(flexmock(:body => ''))
    @connection.should_receive(:post).with(MockDataItemPath,:itemValueDefinitionPath=>'kgCO2PerPassengerJourney',
      :value => 7, :start_date => Time.at(5)).and_return(flexmock(:body => ''))
    @connection.should_receive(:post).with(MockDataItemPath,:itemValueDefinitionPath=>'kgCO2PerPassengerJourney',
      :value => 11, :start_date => Time.at(9)).and_return(flexmock(:body => ''))
    lambda {
      @val.series = TimeSeriesTwo
      @val.save!
    }.should_not raise_error
  end

  it "can have create a new series" do
    @connection.should_receive(:post).with(MockDataItemPath,:itemValueDefinitionPath=>'kgCO2PerPassengerJourney',
      :value => 2, :start_date => Time.at(0)).and_return(flexmock(:body => ''))
    @connection.should_receive(:post).with(MockDataItemPath,:itemValueDefinitionPath=>'kgCO2PerPassengerJourney',
      :value => 6, :start_date => Time.at(1)).and_return(flexmock(:body => ''))
    @connection.should_receive(:post).with(MockDataItemPath,:itemValueDefinitionPath=>'kgCO2PerPassengerJourney',
      :value => 7, :start_date => Time.at(5)).and_return(flexmock(:body => ''))
    @connection.should_receive(:post).with(MockDataItemPath,:itemValueDefinitionPath=>'kgCO2PerPassengerJourney',
      :value => 11, :start_date => Time.at(9)).and_return(flexmock(:body => ''))
    lambda {
      @val.series = TimeSeriesTwo
      @val.create!
    }.should_not raise_error
  end

end
