require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Admin::ItemValueDefinition do

  before(:each) do
    @item_definition = AMEE::Admin::ItemValueDefinition.new
  end
  
  it "should have common AMEE object properties" do
    @item_definition.is_a?(AMEE::Object).should be_true
  end

  it "should have a name" do
    @item_definition.should respond_to(:name)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @item_definition = AMEE::Admin::ItemValueDefinition.new(:uid => uid)
    @item_definition.uid.should == uid
  end

  it "can be created with hash of data" do
    name = "test"
    @item_definition = AMEE::Admin::ItemValueDefinition.new(:name => name)
    @item_definition.name.should == name
  end
  
end

describe AMEE::Admin::ItemValueDefinitionList, "with an authenticated connection" do
   it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><ItemValueDefinitionsResource><Environment uid="5F5887BCF726"/><ItemDefinition uid="BD88D30D1214"/><ItemValueDefinitions><ItemValueDefinition uid="A8A212610A57"><Path>distancePerJourney</Path><Name>Distance per journey</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="D2AB505D2D91"><Path>type</Path><Name>Type</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>true</DrillDown></ItemValueDefinition><ItemValueDefinition uid="41EC337E5C79"><Path>numberOfJourneys</Path><Name>Number of journeys</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="9BAFC976044B"><Path>source</Path><Name>Source</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="9813267B616E"><Path>country</Path><Name>Country</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="263DE76AF8AA"><Path>kgCO2PerPassengerKmIE</Path><Name>kgCO2 Per Passenger Km IE</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="996AE5477B3F"><Name>kgCO2PerKm</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="F5550D71085F"><Path>kgCO2PerKmPassenger</Path><Name>kgCO2 Per Passenger Km</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="996AE5477B3F"><Name>kgCO2PerKm</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="FE166C7602BB"><Path>typicalJourneyDistance</Path><Name>Typical journey distance</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="2F76AB4E3C0F"><Path>journeyFrequency</Path><Name>Journey frequency</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="B0F02E544603"><Path>numberOfPassengers</Path><Name>Number of passengers</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="28D0B8C4F52A"><Path>useTypicalDistance</Path><Name>Use typical distance</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="6334117D28A0"><Path>distanceKmPerMonth</Path><Name>Distance Km Per Month</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="B691497F1CF2"><Name>kM</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><PerUnit>month</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="98EA75911467"><Path>distancePerJourney</Path><Name>Distance per journey</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="584BEA802996"><Path>isReturn</Path><Name>Is return</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="6CBF739E12F0"><Path>distance</Path><Name>Distance</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValueDefinitions></ItemValueDefinitionsResource></Resources>'))
    @data = AMEE::Admin::ItemValueDefinitionList.new(connection,"BD88D30D1214")
    @data.length.should==15
    @data.first.uid.should=='A8A212610A57'
    @data.first.name.should == "Distance per journey"
    @data.first.path.should == "distancePerJourney"
    @data.first.unit.should == "km"
    @data.first.perunit.should == nil
    @data.first.profile?.should == true
    @data.first.drill?.should == false
    @data.first.data?.should == false
  end

   it "should apply block filter correctly" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><ItemValueDefinitionsResource><Environment uid="5F5887BCF726"/><ItemDefinition uid="BD88D30D1214"/><ItemValueDefinitions><ItemValueDefinition uid="A8A212610A57"><Path>distancePerJourney</Path><Name>Distance per journey</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="D2AB505D2D91"><Path>type</Path><Name>Type</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>true</DrillDown></ItemValueDefinition><ItemValueDefinition uid="41EC337E5C79"><Path>numberOfJourneys</Path><Name>Number of journeys</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="9BAFC976044B"><Path>source</Path><Name>Source</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="9813267B616E"><Path>country</Path><Name>Country</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="263DE76AF8AA"><Path>kgCO2PerPassengerKmIE</Path><Name>kgCO2 Per Passenger Km IE</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="996AE5477B3F"><Name>kgCO2PerKm</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="F5550D71085F"><Path>kgCO2PerKmPassenger</Path><Name>kgCO2 Per Passenger Km</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="996AE5477B3F"><Name>kgCO2PerKm</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="FE166C7602BB"><Path>typicalJourneyDistance</Path><Name>Typical journey distance</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="2F76AB4E3C0F"><Path>journeyFrequency</Path><Name>Journey frequency</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="B0F02E544603"><Path>numberOfPassengers</Path><Name>Number of passengers</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="28D0B8C4F52A"><Path>useTypicalDistance</Path><Name>Use typical distance</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="6334117D28A0"><Path>distanceKmPerMonth</Path><Name>Distance Km Per Month</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="B691497F1CF2"><Name>kM</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><PerUnit>month</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="98EA75911467"><Path>distancePerJourney</Path><Name>Distance per journey</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="584BEA802996"><Path>isReturn</Path><Name>Is return</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="6CBF739E12F0"><Path>distance</Path><Name>Distance</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValueDefinitions></ItemValueDefinitionsResource></Resources>'))
    @data = AMEE::Admin::ItemValueDefinitionList.new(connection,"BD88D30D1214") do |x|
      x.uid == 'A8A212610A57' ? x.uid : nil
    end
    @data.length.should==1
    @data.first.should=='A8A212610A57'
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions", {}).and_return(flexmock(:body => '{"environment":{"uid":"5F5887BCF726"},"itemValueDefinitions":[{"uid":"A8A212610A57","unit":"km","name":"Distance per journey","fromData":false,"path":"distancePerJourney","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"D2AB505D2D91","name":"Type","fromData":true,"path":"type","fromProfile":false,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"},"drillDown":true},{"uid":"41EC337E5C79","name":"Number of journeys","fromData":false,"path":"numberOfJourneys","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"9BAFC976044B","name":"Source","fromData":true,"path":"source","fromProfile":false,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"9813267B616E","name":"Country","fromData":false,"path":"country","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"263DE76AF8AA","name":"kgCO2 Per Passenger Km IE","fromData":true,"path":"kgCO2PerPassengerKmIE","fromProfile":false,"valueDefinition":{"uid":"996AE5477B3F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"kgCO2PerKm","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"F5550D71085F","name":"kgCO2 Per Passenger Km","fromData":true,"path":"kgCO2PerKmPassenger","fromProfile":false,"valueDefinition":{"uid":"996AE5477B3F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"kgCO2PerKm","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"FE166C7602BB","name":"Typical journey distance","fromData":true,"path":"typicalJourneyDistance","fromProfile":false,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"2F76AB4E3C0F","name":"Journey frequency","fromData":false,"path":"journeyFrequency","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"B0F02E544603","name":"Number of passengers","fromData":false,"path":"numberOfPassengers","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"28D0B8C4F52A","name":"Use typical distance","fromData":false,"path":"useTypicalDistance","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"perUnit":"month","uid":"6334117D28A0","unit":"km","name":"Distance Km Per Month","fromData":false,"path":"distanceKmPerMonth","fromProfile":true,"valueDefinition":{"uid":"B691497F1CF2","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"kM","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"98EA75911467","unit":"km","name":"Distance per journey","fromData":false,"path":"distancePerJourney","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"uid":"584BEA802996","name":"Is return","fromData":false,"path":"isReturn","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"},"drillDown":false},{"perUnit":"year","uid":"6CBF739E12F0","unit":"km","name":"Distance","fromData":false,"path":"distance","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"drillDown":false}],"itemDefinition":{"uid":"BD88D30D1214"}}'))
    @data = AMEE::Admin::ItemValueDefinitionList.new(connection,"BD88D30D1214")
    @data.length.should==15
    @data.first.uid.should=='A8A212610A57'
    @data.first.name.should == "Distance per journey"
    @data.first.path.should == "distancePerJourney"
    @data.first.unit.should == "km"
    @data.first.perunit.should == nil
    @data.first.profile?.should == true
    @data.first.drill?.should == false
    @data.first.data?.should == false
  end

  it "should fail gracefully with incorrect XML data" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions", {}).and_return(flexmock(:body => xml))
    lambda{AMEE::Admin::ItemValueDefinitionList.new(connection, "BD88D30D1214")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    json = '{}'
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions", {}).and_return(flexmock(:body => json))
    lambda{AMEE::Admin::ItemValueDefinitionList.new(connection, "BD88D30D1214")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions", {}).and_raise("unidentified error")
    lambda{AMEE::Admin::ItemValueDefinitionList.new(connection, "BD88D30D1214")}.should raise_error(AMEE::BadData)
  end
end

describe AMEE::Admin::ItemValueDefinition, "with an authenticated connection" do

  it "should parse profile item XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions/A8A212610A57", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><ItemValueDefinitionResource><ItemValueDefinition created="2009-03-20 00:00:00.0" modified="2009-03-20 00:00:00.0" uid="A8A212610A57"><Path>distancePerJourney</Path><Name>Distance per journey</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown><Value/><Choices/><AllowedRoles/><Environment uid="5F5887BCF726"/><ItemDefinition uid="BD88D30D1214"/><AliasedTo/><APIVersions><APIVersion>2.0</APIVersion></APIVersions></ItemValueDefinition></ItemValueDefinitionResource></Resources>'))
    @data = AMEE::Admin::ItemValueDefinition.load(connection,"BD88D30D1214","A8A212610A57")
    @data.uid.should == "A8A212610A57"
    @data.itemdefuid.should == 'BD88D30D1214'
    @data.created.should == DateTime.new(2009,3,20)
    @data.modified.should == DateTime.new(2009,3,20)
    @data.name.should == "Distance per journey"
    @data.path.should == "distancePerJourney"
    @data.unit.should == "km"
    @data.perunit.should == nil
    @data.profile?.should == true
    @data.drill?.should == false
    @data.data?.should == false
    @data.valuetype.should == 'DECIMAL'
    @data.default.should == nil
    @data.choices.should == []
    @data.versions.should == ['2.0']
    @data.full_path.should == '/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions/A8A212610A57'
  end

  it "should parse data item XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions/9BAFC976044B", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><ItemValueDefinitionResource><ItemValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="9BAFC976044B"><Path>source</Path><Name>Source</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown><Value>42</Value><Choices>foo,bar</Choices><AllowedRoles/><Environment uid="5F5887BCF726"/><ItemDefinition uid="BD88D30D1214"/><AliasedTo/><APIVersions><APIVersion>1.0</APIVersion><APIVersion>2.0</APIVersion></APIVersions></ItemValueDefinition></ItemValueDefinitionResource></Resources>'))

    @data = AMEE::Admin::ItemValueDefinition.load(connection,"BD88D30D1214","9BAFC976044B")
    @data.uid.should == "9BAFC976044B"
    @data.itemdefuid.should == 'BD88D30D1214'
    @data.created.should == DateTime.new(2007,7,27,9,30,44)
    @data.modified.should == DateTime.new(2007,7,27,9,30,44)
    @data.name.should == "Source"
    @data.path.should == "source"
    @data.unit.should == nil
    @data.perunit.should == nil
    @data.profile?.should == false
    @data.drill?.should == false
    @data.data?.should == true
    @data.valuetype.should == 'TEXT'
    @data.default.should == "42"
    @data.choices.should == ['foo', 'bar']
    @data.versions.should == ['1.0', '2.0']
  end

  it "should parse drill item XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions/D2AB505D2D91", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><ItemValueDefinitionResource><ItemValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="D2AB505D2D91"><Path>type</Path><Name>Type</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>true</DrillDown><Value/><Choices/><AllowedRoles/><Environment uid="5F5887BCF726"/><ItemDefinition uid="BD88D30D1214"/><AliasedTo/><APIVersions><APIVersion>1.0</APIVersion><APIVersion>2.0</APIVersion></APIVersions></ItemValueDefinition></ItemValueDefinitionResource></Resources>'))
    @data = AMEE::Admin::ItemValueDefinition.load(connection,"BD88D30D1214","D2AB505D2D91")
    @data.uid.should == "D2AB505D2D91"
    @data.itemdefuid.should == 'BD88D30D1214'
    @data.created.should == DateTime.new(2007,7,27,9,30,44)
    @data.modified.should == DateTime.new(2007,7,27,9,30,44)
    @data.name.should == "Type"
    @data.path.should == "type"
    @data.unit.should == nil
    @data.perunit.should == nil
    @data.profile?.should == false
    @data.drill?.should == true
    @data.data?.should == false
    @data.valuetype.should == 'TEXT'
    @data.default.should == nil
    @data.choices.should == []
    @data.versions.should == ['1.0', '2.0']
  end

  it "should parse profile item JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions/A8A212610A57", {}).and_return(flexmock(:body => '{"itemValueDefinition":{"uid":"A8A212610A57","choices":"","itemDefinition":{"uid":"BD88D30D1214"},"fromProfile":true,"drillDown":false,"modified":"2009-03-20 00:00:00.0","unit":"km","apiVersions":[{"apiVersion":"2.0"}],"environment":{"uid":"5F5887BCF726"},"created":"2009-03-20 00:00:00.0","name":"Distance per journey","path":"distancePerJourney","fromData":false,"value":"","aliasedTo":null,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 09:30:44.0"},"allowedRoles":""}}'))
    @data = AMEE::Admin::ItemValueDefinition.load(connection,"BD88D30D1214","A8A212610A57")
    @data.uid.should == "A8A212610A57"
    @data.itemdefuid.should == 'BD88D30D1214'
    @data.created.should == DateTime.new(2009,3,20)
    @data.modified.should == DateTime.new(2009,3,20)
    @data.name.should == "Distance per journey"
    @data.path.should == "distancePerJourney"
    @data.unit.should == "km"
    @data.perunit.should == nil
    @data.profile?.should == true
    @data.drill?.should == false
    @data.data?.should == false
    @data.valuetype.should == 'DECIMAL'
    @data.default.should == nil
    @data.choices.should == []
    @data.versions.should == ['2.0']
    @data.full_path.should == '/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions/A8A212610A57'
  end

  it "should parse data item JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions/9BAFC976044B", {}).and_return(flexmock(:body => '{"itemValueDefinition":{"uid":"9BAFC976044B","choices":"foo,bar","itemDefinition":{"uid":"BD88D30D1214"},"fromProfile":false,"drillDown":false,"modified":"2007-07-27 09:30:44.0","apiVersions":[{"apiVersion":"1.0"},{"apiVersion":"2.0"}],"environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","name":"Source","path":"source","fromData":true,"value":"42","aliasedTo":null,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"},"allowedRoles":""}}'))

    @data = AMEE::Admin::ItemValueDefinition.load(connection,"BD88D30D1214","9BAFC976044B")
    @data.uid.should == "9BAFC976044B"
    @data.itemdefuid.should == 'BD88D30D1214'
    @data.created.should == DateTime.new(2007,7,27,9,30,44)
    @data.modified.should == DateTime.new(2007,7,27,9,30,44)
    @data.name.should == "Source"
    @data.path.should == "source"
    @data.unit.should == nil
    @data.perunit.should == nil
    @data.profile?.should == false
    @data.drill?.should == false
    @data.data?.should == true
    @data.valuetype.should == 'TEXT'
    @data.default.should == "42"
    @data.choices.should == ['foo', 'bar']
    @data.versions.should == ['1.0', '2.0']
  end

  it "should parse drill item JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions/D2AB505D2D91", {}).and_return(flexmock(:body => '{"itemValueDefinition":{"uid":"D2AB505D2D91","choices":"","itemDefinition":{"uid":"BD88D30D1214"},"fromProfile":false,"drillDown":true,"modified":"2007-07-27 09:30:44.0","apiVersions":[{"apiVersion":"1.0"},{"apiVersion":"2.0"}],"environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","name":"Type","path":"type","fromData":true,"value":"","aliasedTo":null,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"},"allowedRoles":""}}'))
    @data = AMEE::Admin::ItemValueDefinition.load(connection,"BD88D30D1214","D2AB505D2D91")
    @data.uid.should == "D2AB505D2D91"
    @data.itemdefuid.should == 'BD88D30D1214'
    @data.created.should == DateTime.new(2007,7,27,9,30,44)
    @data.modified.should == DateTime.new(2007,7,27,9,30,44)
    @data.name.should == "Type"
    @data.path.should == "type"
    @data.unit.should == nil
    @data.perunit.should == nil
    @data.profile?.should == false
    @data.drill?.should == true
    @data.data?.should == false
    @data.valuetype.should == 'TEXT'
    @data.default.should == nil
    @data.choices.should == []
    @data.versions.should == ['1.0', '2.0']
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:get).with("/admin", {}).and_return(flexmock(:body => xml))
    lambda{AMEE::Admin::ItemValueDefinition.get(connection, "/admin")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    json = '{}'
    connection.should_receive(:get).with("/admin", {}).and_return(flexmock(:body => json))
    lambda{AMEE::Admin::ItemValueDefinition.get(connection, "/admin")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/admin", {}).and_raise("unidentified error")
    lambda{AMEE::Admin::ItemValueDefinition.get(connection, "/admin")}.should raise_error(AMEE::BadData)
  end

end