require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::Item do

  before(:each) do
    @item = AMEE::Data::Item.new
  end
  
  it "should have common AMEE object properties" do
    @item.is_a?(AMEE::Data::Object).should be_true
  end
  
  it "should have values" do
    @item.should respond_to(:values)
  end

  it "should have values" do
    @item.should respond_to(:choices)
  end

  it "should a label" do
    @item.should respond_to(:label)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @item = AMEE::Data::Item.new(:uid => uid)
    @item.uid.should == uid
  end

  it "can be created with hash of data" do
    values = ["one", "two"]
    choices = [{:name => "one", :value => "two"}]
    label = "test"
    @item = AMEE::Data::Item.new(:label => label, :values => values, :choices => choices)
    @item.values.should == values
    @item.choices.should == choices
    @item.label.should == label
  end
  
end

describe AMEE::Data::Item, "with an authenticated connection" do

  it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DataItemResource><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="AD63A83B4D41"><Name>AD63A83B4D41</Name><ItemValues><ItemValue uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><Value>0</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="7F27A5707101"><Path>kgCO2PerPassengerKm</Path><Name>kgCO2 Per Passenger Km</Name><Value>0.158</Value><ItemValueDefinition uid="D7B4340D9404"><Path>kgCO2PerPassengerKm</Path><Name>kgCO2 Per Passenger Km</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="996AE5477B3F"><Name>kgCO2PerKm</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="FF50EC918A8E"><Path>size</Path><Name>Size</Name><Value>-</Value><ItemValueDefinition uid="5D7FB5F552A5"><Path>size</Path><Name>Size</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="FDD62D27AA15"><Path>type</Path><Name>Type</Name><Value>domestic</Value><ItemValueDefinition uid="C376560CB19F"><Path>type</Path><Name>Type</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="9BE08FBEC54E"><Path>source</Path><Name>Source</Name><Value>DfT INAS Division, 29 March 2007</Value><ItemValueDefinition uid="0F0592F05AAC"><Path>source</Path><Name>Source</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType></ValueDefinition></ItemValueDefinition></ItemValue></ItemValues><Environment uid="5F5887BCF726"/><ItemDefinition uid="441BF4BEA15B"/><DataCategory uid="FBA97B70DBDF"><Name>Generic</Name><Path>generic</Path></DataCategory><Path>AD63A83B4D41</Path><Label>domestic</Label></DataItem><Path>/transport/plane/generic/AD63A83B4D41</Path><Choices><Name>userValueChoices</Name><Choices><Choice><Name>distanceKmPerYear</Name><Value/></Choice><Choice><Name>journeysPerYear</Name><Value/></Choice><Choice><Name>lat1</Name><Value>-999</Value></Choice><Choice><Name>lat2</Name><Value>-999</Value></Choice><Choice><Name>long1</Name><Value>-999</Value></Choice><Choice><Name>long2</Name><Value>-999</Value></Choice></Choices></Choices><AmountPerMonth>0.000</AmountPerMonth></DataItemResource></Resources>')
    @data = AMEE::Data::Item.get(connection, "/data/transport/plane/generic/AD63A83B4D41")
    @data.uid.should == "AD63A83B4D41"
    @data.path.should == "/transport/plane/generic/AD63A83B4D41"
    @data.full_path.should == "/data/transport/plane/generic/AD63A83B4D41"
    @data.created.should == DateTime.new(2007,8,1,9,00,41)
    @data.modified.should == DateTime.new(2007,8,1,9,00,41)
    @data.label.should == "domestic"
    @data.item_definition.should == "441BF4BEA15B"
    @data.values.size.should == 5
    @data.values[0][:name].should == "kgCO2 Per Passenger Journey"
    @data.values[0][:path].should == "kgCO2PerPassengerJourney"
    @data.values[0][:value].should == "0"
    @data.values[0][:uid].should == "127612FA4921"
  end

  it "should parse choices correctly from XML" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DataItemResource><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="AD63A83B4D41"><Name>AD63A83B4D41</Name><ItemValues><ItemValue uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><Value>0</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="7F27A5707101"><Path>kgCO2PerPassengerKm</Path><Name>kgCO2 Per Passenger Km</Name><Value>0.158</Value><ItemValueDefinition uid="D7B4340D9404"><Path>kgCO2PerPassengerKm</Path><Name>kgCO2 Per Passenger Km</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="996AE5477B3F"><Name>kgCO2PerKm</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="FF50EC918A8E"><Path>size</Path><Name>Size</Name><Value>-</Value><ItemValueDefinition uid="5D7FB5F552A5"><Path>size</Path><Name>Size</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="FDD62D27AA15"><Path>type</Path><Name>Type</Name><Value>domestic</Value><ItemValueDefinition uid="C376560CB19F"><Path>type</Path><Name>Type</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="9BE08FBEC54E"><Path>source</Path><Name>Source</Name><Value>DfT INAS Division, 29 March 2007</Value><ItemValueDefinition uid="0F0592F05AAC"><Path>source</Path><Name>Source</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType></ValueDefinition></ItemValueDefinition></ItemValue></ItemValues><Environment uid="5F5887BCF726"/><ItemDefinition uid="441BF4BEA15B"/><DataCategory uid="FBA97B70DBDF"><Name>Generic</Name><Path>generic</Path></DataCategory><Path>AD63A83B4D41</Path><Label>domestic</Label></DataItem><Path>/transport/plane/generic/AD63A83B4D41</Path><Choices><Name>userValueChoices</Name><Choices><Choice><Name>distanceKmPerYear</Name><Value/></Choice><Choice><Name>journeysPerYear</Name><Value/></Choice><Choice><Name>lat1</Name><Value>-999</Value></Choice><Choice><Name>lat2</Name><Value>-999</Value></Choice><Choice><Name>long1</Name><Value>-999</Value></Choice><Choice><Name>long2</Name><Value>-999</Value></Choice></Choices></Choices><AmountPerMonth>0.000</AmountPerMonth></DataItemResource></Resources>')
    @data = AMEE::Data::Item.get(connection, "/data/transport/plane/generic/AD63A83B4D41")
    @data.choices.size.should == 6
    @data.choices[0][:name].should == "distanceKmPerYear"
    @data.choices[0][:value].should be_empty
    @data.choices[1][:name].should == "journeysPerYear"
    @data.choices[1][:value].should be_empty
    @data.choices[2][:name].should == "lat1"
    @data.choices[2][:value].should == "-999"
    @data.choices[3][:name].should == "lat2"
    @data.choices[3][:value].should == "-999"
    @data.choices[4][:name].should == "long1"
    @data.choices[4][:value].should == "-999"
    @data.choices[5][:name].should == "long2"
    @data.choices[5][:value].should == "-999"
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41").and_return('{"amountPerMonth":0,"userValueChoices":{"choices":[{"value":"","name":"distanceKmPerYear"},{"value":"","name":"journeysPerYear"},{"value":"-999","name":"lat1"},{"value":"-999","name":"lat2"},{"value":"-999","name":"long1"},{"value":"-999","name":"long2"}],"name":"userValueChoices"},"path":"/transport/plane/generic/AD63A83B4D41","dataItem":{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","itemDefinition":{"uid":"441BF4BEA15B"},"itemValues":[{"value":"0","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}},{"value":"0.158","uid":"7F27A5707101","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"996AE5477B3F","name":"kgCO2PerKm"},"uid":"D7B4340D9404","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km"}},{"value":"-","uid":"FF50EC918A8E","path":"size","name":"Size","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"5D7FB5F552A5","path":"size","name":"Size"}},{"value":"domestic","uid":"FDD62D27AA15","path":"type","name":"Type","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"C376560CB19F","path":"type","name":"Type"}},{"value":"DfT INAS Division, 29 March 2007","uid":"9BE08FBEC54E","path":"source","name":"Source","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"0F0592F05AAC","path":"source","name":"Source"}}],"label":"domestic","dataCategory":{"uid":"FBA97B70DBDF","path":"generic","name":"Generic"},"uid":"AD63A83B4D41","environment":{"uid":"5F5887BCF726"},"path":"","name":"AD63A83B4D41"}}')
    @data = AMEE::Data::Item.get(connection, "/data/transport/plane/generic/AD63A83B4D41")
    @data.uid.should == "AD63A83B4D41"
    @data.path.should == "/transport/plane/generic/AD63A83B4D41"
    @data.full_path.should == "/data/transport/plane/generic/AD63A83B4D41"
    @data.created.should == DateTime.new(2007,8,1,9,00,41)
    @data.modified.should == DateTime.new(2007,8,1,9,00,41)
    @data.label.should == "domestic"
    @data.values.size.should == 5
    @data.values[0][:name].should == "kgCO2 Per Passenger Journey"
    @data.values[0][:path].should == "kgCO2PerPassengerJourney"
    @data.values[0][:value].should == "0"
    @data.values[0][:uid].should == "127612FA4921"
  end

  it "should parse choices correctly from JSON" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41").and_return('{"amountPerMonth":0,"userValueChoices":{"choices":[{"value":"","name":"distanceKmPerYear"},{"value":"","name":"journeysPerYear"},{"value":"-999","name":"lat1"},{"value":"-999","name":"lat2"},{"value":"-999","name":"long1"},{"value":"-999","name":"long2"}],"name":"userValueChoices"},"path":"/transport/plane/generic/AD63A83B4D41","dataItem":{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","itemDefinition":{"uid":"441BF4BEA15B"},"itemValues":[{"value":"0","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}},{"value":"0.158","uid":"7F27A5707101","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"996AE5477B3F","name":"kgCO2PerKm"},"uid":"D7B4340D9404","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km"}},{"value":"-","uid":"FF50EC918A8E","path":"size","name":"Size","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"5D7FB5F552A5","path":"size","name":"Size"}},{"value":"domestic","uid":"FDD62D27AA15","path":"type","name":"Type","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"C376560CB19F","path":"type","name":"Type"}},{"value":"DfT INAS Division, 29 March 2007","uid":"9BE08FBEC54E","path":"source","name":"Source","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"0F0592F05AAC","path":"source","name":"Source"}}],"label":"domestic","dataCategory":{"uid":"FBA97B70DBDF","path":"generic","name":"Generic"},"uid":"AD63A83B4D41","environment":{"uid":"5F5887BCF726"},"path":"","name":"AD63A83B4D41"}}')
    @data = AMEE::Data::Item.get(connection, "/data/transport/plane/generic/AD63A83B4D41")
    @data.choices.size.should == 6
    @data.choices[0][:name].should == "distanceKmPerYear"
    @data.choices[0][:value].should be_empty
    @data.choices[1][:name].should == "journeysPerYear"
    @data.choices[1][:value].should be_empty
    @data.choices[2][:name].should == "lat1"
    @data.choices[2][:value].should == "-999"
    @data.choices[3][:name].should == "lat2"
    @data.choices[3][:value].should == "-999"
    @data.choices[4][:name].should == "long1"
    @data.choices[4][:value].should == "-999"
    @data.choices[5][:name].should == "long2"
    @data.choices[5][:value].should == "-999"
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>')
    lambda{AMEE::Data::Item.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItem from XML. Check that your URL is correct.")
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('{}')
    lambda{AMEE::Data::Item.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItem from JSON. Check that your URL is correct.")
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_raise("unidentified error")
    lambda{AMEE::Data::Item.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItem. Check that your URL is correct.")
  end

end

describe "with sensible data" do

  it "allows client to get a value by name" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41").and_return('{"amountPerMonth":0,"userValueChoices":{"choices":[{"value":"","name":"distanceKmPerYear"},{"value":"","name":"journeysPerYear"},{"value":"-999","name":"lat1"},{"value":"-999","name":"lat2"},{"value":"-999","name":"long1"},{"value":"-999","name":"long2"}],"name":"userValueChoices"},"path":"/transport/plane/generic/AD63A83B4D41","dataItem":{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","itemDefinition":{"uid":"441BF4BEA15B"},"itemValues":[{"value":"0","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}},{"value":"0.158","uid":"7F27A5707101","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"996AE5477B3F","name":"kgCO2PerKm"},"uid":"D7B4340D9404","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km"}},{"value":"-","uid":"FF50EC918A8E","path":"size","name":"Size","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"5D7FB5F552A5","path":"size","name":"Size"}},{"value":"domestic","uid":"FDD62D27AA15","path":"type","name":"Type","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"C376560CB19F","path":"type","name":"Type"}},{"value":"DfT INAS Division, 29 March 2007","uid":"9BE08FBEC54E","path":"source","name":"Source","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"0F0592F05AAC","path":"source","name":"Source"}}],"label":"domestic","dataCategory":{"uid":"FBA97B70DBDF","path":"generic","name":"Generic"},"uid":"AD63A83B4D41","environment":{"uid":"5F5887BCF726"},"path":"","name":"AD63A83B4D41"}}')
    @data = AMEE::Data::Item.get(connection, "/data/transport/plane/generic/AD63A83B4D41")
    @data.value("kgCO2 Per Passenger Km").should_not be_nil
    @data.value("Source").should_not be_nil
  end

  it "allows client to get a value by path" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41").and_return('{"amountPerMonth":0,"userValueChoices":{"choices":[{"value":"","name":"distanceKmPerYear"},{"value":"","name":"journeysPerYear"},{"value":"-999","name":"lat1"},{"value":"-999","name":"lat2"},{"value":"-999","name":"long1"},{"value":"-999","name":"long2"}],"name":"userValueChoices"},"path":"/transport/plane/generic/AD63A83B4D41","dataItem":{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","itemDefinition":{"uid":"441BF4BEA15B"},"itemValues":[{"value":"0","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}},{"value":"0.158","uid":"7F27A5707101","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"996AE5477B3F","name":"kgCO2PerKm"},"uid":"D7B4340D9404","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km"}},{"value":"-","uid":"FF50EC918A8E","path":"size","name":"Size","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"5D7FB5F552A5","path":"size","name":"Size"}},{"value":"domestic","uid":"FDD62D27AA15","path":"type","name":"Type","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"C376560CB19F","path":"type","name":"Type"}},{"value":"DfT INAS Division, 29 March 2007","uid":"9BE08FBEC54E","path":"source","name":"Source","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"0F0592F05AAC","path":"source","name":"Source"}}],"label":"domestic","dataCategory":{"uid":"FBA97B70DBDF","path":"generic","name":"Generic"},"uid":"AD63A83B4D41","environment":{"uid":"5F5887BCF726"},"path":"","name":"AD63A83B4D41"}}')
    @data = AMEE::Data::Item.get(connection, "/data/transport/plane/generic/AD63A83B4D41")
    @data.value("kgCO2PerPassengerKm").should_not be_nil
    @data.value("source").should_not be_nil
  end

  it "allows update" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41").and_return('{"amountPerMonth":0,"userValueChoices":{"choices":[{"value":"","name":"distanceKmPerYear"},{"value":"","name":"journeysPerYear"},{"value":"-999","name":"lat1"},{"value":"-999","name":"lat2"},{"value":"-999","name":"long1"},{"value":"-999","name":"long2"}],"name":"userValueChoices"},"path":"/transport/plane/generic/AD63A83B4D41","dataItem":{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","itemDefinition":{"uid":"441BF4BEA15B"},"itemValues":[{"value":"0","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}},{"value":"0.158","uid":"7F27A5707101","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"996AE5477B3F","name":"kgCO2PerKm"},"uid":"D7B4340D9404","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km"}},{"value":"-","uid":"FF50EC918A8E","path":"size","name":"Size","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"5D7FB5F552A5","path":"size","name":"Size"}},{"value":"domestic","uid":"FDD62D27AA15","path":"type","name":"Type","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"C376560CB19F","path":"type","name":"Type"}},{"value":"DfT INAS Division, 29 March 2007","uid":"9BE08FBEC54E","path":"source","name":"Source","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"0F0592F05AAC","path":"source","name":"Source"}}],"label":"domestic","dataCategory":{"uid":"FBA97B70DBDF","path":"generic","name":"Generic"},"uid":"AD63A83B4D41","environment":{"uid":"5F5887BCF726"},"path":"","name":"AD63A83B4D41"}}')
    connection.should_receive(:put).with("/data/transport/plane/generic/AD63A83B4D41", :kgCO2PerPassengerKm => 0.159).and_return('{"amountPerMonth":0,"userValueChoices":{"choices":[{"value":"","name":"distanceKmPerYear"},{"value":"","name":"journeysPerYear"},{"value":"-999","name":"lat1"},{"value":"-999","name":"lat2"},{"value":"-999","name":"long1"},{"value":"-999","name":"long2"}],"name":"userValueChoices"},"path":"/transport/plane/generic/AD63A83B4D41","dataItem":{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","itemDefinition":{"uid":"441BF4BEA15B"},"itemValues":[{"value":"0","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}},{"value":"0.159","uid":"7F27A5707101","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"996AE5477B3F","name":"kgCO2PerKm"},"uid":"D7B4340D9404","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km"}},{"value":"-","uid":"FF50EC918A8E","path":"size","name":"Size","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"5D7FB5F552A5","path":"size","name":"Size"}},{"value":"domestic","uid":"FDD62D27AA15","path":"type","name":"Type","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"C376560CB19F","path":"type","name":"Type"}},{"value":"DfT INAS Division, 29 March 2007","uid":"9BE08FBEC54E","path":"source","name":"Source","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"0F0592F05AAC","path":"source","name":"Source"}}],"label":"domestic","dataCategory":{"uid":"FBA97B70DBDF","path":"generic","name":"Generic"},"uid":"AD63A83B4D41","environment":{"uid":"5F5887BCF726"},"path":"","name":"AD63A83B4D41"}}')
    @data = AMEE::Data::Item.get(connection, "/data/transport/plane/generic/AD63A83B4D41")
    @data.value("kgCO2PerPassengerKm").should == "0.158"
    @data.update(:kgCO2PerPassengerKm => 0.159)
    #@data.value("kgCO2PerPassengerKm").should == "0.159"
  end
  
  it "fails gracefully if update fails" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41").and_return('{"amountPerMonth":0,"userValueChoices":{"choices":[{"value":"","name":"distanceKmPerYear"},{"value":"","name":"journeysPerYear"},{"value":"-999","name":"lat1"},{"value":"-999","name":"lat2"},{"value":"-999","name":"long1"},{"value":"-999","name":"long2"}],"name":"userValueChoices"},"path":"/transport/plane/generic/AD63A83B4D41","dataItem":{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","itemDefinition":{"uid":"441BF4BEA15B"},"itemValues":[{"value":"0","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}},{"value":"0.158","uid":"7F27A5707101","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"996AE5477B3F","name":"kgCO2PerKm"},"uid":"D7B4340D9404","path":"kgCO2PerPassengerKm","name":"kgCO2 Per Passenger Km"}},{"value":"-","uid":"FF50EC918A8E","path":"size","name":"Size","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"5D7FB5F552A5","path":"size","name":"Size"}},{"value":"domestic","uid":"FDD62D27AA15","path":"type","name":"Type","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"C376560CB19F","path":"type","name":"Type"}},{"value":"DfT INAS Division, 29 March 2007","uid":"9BE08FBEC54E","path":"source","name":"Source","itemValueDefinition":{"valueDefinition":{"valueType":"TEXT","uid":"CCEB59CACE1B","name":"text"},"uid":"0F0592F05AAC","path":"source","name":"Source"}}],"label":"domestic","dataCategory":{"uid":"FBA97B70DBDF","path":"generic","name":"Generic"},"uid":"AD63A83B4D41","environment":{"uid":"5F5887BCF726"},"path":"","name":"AD63A83B4D41"}}')
    connection.should_receive(:put).with("/data/transport/plane/generic/AD63A83B4D41", :kgCO2PerPassengerKm => 0.159).and_raise("generic error")
    @data = AMEE::Data::Item.get(connection, "/data/transport/plane/generic/AD63A83B4D41")
    lambda{@data.update(:kgCO2PerPassengerKm => 0.159)}.should raise_error(AMEE::BadData, "Couldn't update DataItem. Check that your information is correct.")
  end

  
end