require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::Item do

  before(:each) do
    @item = AMEE::Data::Item.new
  end
  
  it "should have common AMEE object properties" do
    @item.is_a?(AMEE::Object).should be_true
  end
  
  it "should have values" do
    @item.should respond_to(:values)
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
    label = "test"
    @item = AMEE::Data::Item.new(:label => label, :values => values)
    @item.values.should == values
    @item.label.should == label
  end
  
end

describe AMEE::Data::Item, "with an authenticated connection" do

  it "should parse correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic/AD63A83B4D41").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DataItemResource><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="AD63A83B4D41"><Name>AD63A83B4D41</Name><ItemValues><ItemValue uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><Value>0</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="7F27A5707101"><Path>kgCO2PerPassengerKm</Path><Name>kgCO2 Per Passenger Km</Name><Value>0.158</Value><ItemValueDefinition uid="D7B4340D9404"><Path>kgCO2PerPassengerKm</Path><Name>kgCO2 Per Passenger Km</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="996AE5477B3F"><Name>kgCO2PerKm</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="FF50EC918A8E"><Path>size</Path><Name>Size</Name><Value>-</Value><ItemValueDefinition uid="5D7FB5F552A5"><Path>size</Path><Name>Size</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="FDD62D27AA15"><Path>type</Path><Name>Type</Name><Value>domestic</Value><ItemValueDefinition uid="C376560CB19F"><Path>type</Path><Name>Type</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="9BE08FBEC54E"><Path>source</Path><Name>Source</Name><Value>DfT INAS Division, 29 March 2007</Value><ItemValueDefinition uid="0F0592F05AAC"><Path>source</Path><Name>Source</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType></ValueDefinition></ItemValueDefinition></ItemValue></ItemValues><Environment uid="5F5887BCF726"/><ItemDefinition uid="441BF4BEA15B"/><DataCategory uid="FBA97B70DBDF"><Name>Generic</Name><Path>generic</Path></DataCategory><Path>AD63A83B4D41</Path><Label>domestic</Label></DataItem><Path>/transport/plane/generic/AD63A83B4D41</Path><Choices><Name>userValueChoices</Name><Choices><Choice><Name>distanceKmPerYear</Name><Value/></Choice><Choice><Name>journeysPerYear</Name><Value/></Choice><Choice><Name>lat1</Name><Value>-999</Value></Choice><Choice><Name>lat2</Name><Value>-999</Value></Choice><Choice><Name>long1</Name><Value>-999</Value></Choice><Choice><Name>long2</Name><Value>-999</Value></Choice></Choices></Choices><AmountPerMonth>0.000</AmountPerMonth></DataItemResource></Resources>')
    @data = AMEE::Data::Item.get(connection, "/data/transport/plane/generic/AD63A83B4D41")
    @data.uid.should == "AD63A83B4D41"
    @data.path.should == "/transport/plane/generic/AD63A83B4D41"
    @data.created.should == DateTime.new(2007,8,1,9,00,41)
    @data.modified.should == DateTime.new(2007,8,1,9,00,41)
    @data.modified.should == DateTime.new(2007,8,1,9,00,41)
    @data.label.should == "domestic"
    @data.values.size.should == 5
    @data.values[0][:name].should == "kgCO2 Per Passenger Journey"
    @data.values[0][:path].should == "kgCO2PerPassengerJourney"
    @data.values[0][:value].should == "0"
    @data.values[0][:uid].should == "127612FA4921"
  end

end