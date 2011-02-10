require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::Category do

  before(:each) do
    @cat = AMEE::Data::Category.new
  end

  it "should have common AMEE object properties" do
    @cat.is_a?(AMEE::Data::Object).should be_true
  end

  it "should have children" do
    @cat.should respond_to(:children)
  end

  it "should have items" do
    @cat.should respond_to(:items)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @cat = AMEE::Data::Category.new(:uid => uid)
    @cat.uid.should == uid
  end

  it "can be created with hash of data" do
    children = ["one", "two"]
    items = ["three", "four"]
    @cat = AMEE::Data::Category.new(:children => children, :items => items)
    @cat.children.should == children
    @cat.items.should == items
  end

end

describe AMEE::Data::Category, "accessing AMEE V0" do

  it "should provide access to root of Data API" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><DataCategory created="2007-04-16 17:50:43.0" modified="2007-04-16 17:50:43.0" uid="63EA08D29C63"><name>Root</name><path/></DataCategory><Children><DataCategories><DataCategory uid="5376F191D80E"><name>Metadata</name><path>metadata</path></DataCategory><DataCategory uid="33F9A55AA555"><name>Transport</name><path>transport</path></DataCategory><DataCategory uid="248D8617A389"><name>Home</name><path>home</path></DataCategory></DataCategories></Children></DataCategoryResource></Resources>'))
    @root = AMEE::Data::Category.root(connection)
    @root.name.should == "Root"
    @root.path.should == ""
    @root.full_path.should == "/data"
    @root.uid.should == "63EA08D29C63"
    @root.created.should == DateTime.new(2007,4,16,17,50,43)
    @root.modified.should == DateTime.new(2007,4,16,17,50,43)
    @root.pager.should be_nil
    @root.children.size.should be(3)
    @root.children[0][:uid].should == "5376F191D80E"
    @root.children[0][:name].should == "Metadata"
    @root.children[0][:path].should == "metadata"
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data/home/fuel", {:itemsPerPage => 10}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><DataCategory created="2007-04-16 17:50:43.0" modified="2007-04-16 17:50:43.0" uid="8B5A3EF67252"><name>Fuel</name><path>fuel</path></DataCategory><Children><DataCategories/><DataItems><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="9DC114F06AB2"><fuelKgCO2PerKWh>0</fuelKgCO2PerKWh><fuelKgCO2perKg>0</fuelKgCO2perKg><fuelKgCO2PerLitre>2.5</fuelKgCO2PerLitre><label>Biodiesel</label><fuelType>Biodiesel</fuelType><fuelSource>AMEE 2007</fuelSource></DataItem><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="B1F3D29987BF"><fuelKgCO2PerKWh>0</fuelKgCO2PerKWh><fuelKgCO2perKg>0.1316</fuelKgCO2perKg><fuelKgCO2PerLitre>0</fuelKgCO2PerLitre><label>Biomass</label><fuelType>Biomass</fuelType><fuelSource>defra 2008</fuelSource></DataItem><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="D29131D9FA60"><fuelKgCO2PerKWh>0</fuelKgCO2PerKWh><fuelKgCO2perKg>2.506</fuelKgCO2perKg><fuelKgCO2PerLitre>0</fuelKgCO2PerLitre><label>Coal</label><fuelType>Coal</fuelType><fuelSource>defra 2008</fuelSource></DataItem><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="3406EECDCDF8"><fuelKgCO2PerKWh>0</fuelKgCO2PerKWh><fuelKgCO2perKg>0</fuelKgCO2perKg><fuelKgCO2PerLitre>2.6287</fuelKgCO2PerLitre><label>Diesel</label><fuelType>Diesel</fuelType><fuelSource>defra 2008</fuelSource></DataItem><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="FFAD4D7A54D7"><fuelKgCO2PerKWh>0.537</fuelKgCO2PerKWh><fuelKgCO2perKg>0</fuelKgCO2perKg><fuelKgCO2PerLitre>0</fuelKgCO2PerLitre><label>Electricity</label><fuelType>Electricity</fuelType><fuelSource>defra 2008</fuelSource></DataItem><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="160B6EAA8739"><fuelKgCO2PerKWh>0.2055</fuelKgCO2PerKWh><fuelKgCO2perKg>0</fuelKgCO2perKg><fuelKgCO2PerLitre>0</fuelKgCO2PerLitre><label>Gas</label><fuelType>Gas</fuelType><fuelSource>defra 2008</fuelSource></DataItem><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="22824F2E4FF7"><fuelKgCO2PerKWh>0</fuelKgCO2PerKWh><fuelKgCO2perKg>0</fuelKgCO2perKg><fuelKgCO2PerLitre>2.516</fuelKgCO2PerLitre><label>Kerosene</label><fuelType>Kerosene</fuelType><fuelSource>defra 2008</fuelSource></DataItem><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="B55687DB4AC9"><fuelKgCO2PerKWh>0</fuelKgCO2PerKWh><fuelKgCO2perKg>0</fuelKgCO2perKg><fuelKgCO2PerLitre>1.495</fuelKgCO2PerLitre><label>LPG</label><fuelType>LPG</fuelType><fuelSource>defra 2008</fuelSource></DataItem><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="D12017B42CC3"><fuelKgCO2PerKWh>0</fuelKgCO2PerKWh><fuelKgCO2perKg>0</fuelKgCO2perKg><fuelKgCO2PerLitre>2.518</fuelKgCO2PerLitre><label>Oil</label><fuelType>Oil</fuelType><fuelSource>defra 2008</fuelSource></DataItem><DataItem created="2007-04-16 18:03:47.0" modified="2007-04-16 18:03:47.0" uid="62110A147736"><fuelKgCO2PerKWh>0</fuelKgCO2PerKWh><fuelKgCO2perKg>0</fuelKgCO2perKg><fuelKgCO2PerLitre>2.3167</fuelKgCO2PerLitre><label>Petrol</label><fuelType>Petrol</fuelType><fuelSource>defra 2008</fuelSource></DataItem></DataItems></Children></DataCategoryResource></Resources>'))
    @data = AMEE::Data::Category.get(connection, "/data/home/fuel")
    @data.uid.should == "8B5A3EF67252"
    @data.items.size.should be(10)
    @data.items[0][:uid].should == "9DC114F06AB2"
    @data.items[0][:label].should == "Biodiesel"
    @data.items[0][:path].should == "9DC114F06AB2"
    @data.items[0][:fuelKgCO2PerLitre].should == "2.5"
    @data.pager.should be_nil
  end

end

describe AMEE::Data::Category, "with an authenticated XML connection" do

  it "should provide access to root of Data API" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('data.xml')))
    @root = AMEE::Data::Category.root(connection)
    @root.name.should == "Root"
    @root.path.should == ""
    @root.full_path.should == "/data"
    @root.uid.should == "CD310BEBAC52"
    @root.created.should == DateTime.new(2007,7,27,9,30,44)
    @root.modified.should == DateTime.new(2007,7,27,9,30,44)
    @root.children.size.should be(5)
    @root.children[0][:uid].should == "BBA3AC3E795E"
    @root.children[0][:name].should == "Home"
    @root.children[0][:path].should == "home"
    @root.pager.should be_nil
  end

  it "should provide access to child objects" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('data.xml')))
    connection.should_receive(:get).with("/data/transport", {:itemsPerPage => 10}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path>/transport</Path><DataCategory created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="263FC0186834"><Name>Transport</Name><Path>transport</Path><Environment uid="5F5887BCF726"/><DataCategory uid="CD310BEBAC52"><Name>Root</Name><Path/></DataCategory></DataCategory><Children><DataCategories><DataCategory uid="3C4705614170"><Name>Bus</Name><Path>bus</Path></DataCategory><DataCategory uid="1D95119FB149"><Name>Car</Name><Path>car</Path></DataCategory><DataCategory uid="83C4FAF4826A"><Name>Motorcycle</Name><Path>motorcycle</Path></DataCategory><DataCategory uid="AFB73A5D2E45"><Name>Other</Name><Path>Other</Path></DataCategory><DataCategory uid="6F3692D81CD9"><Name>Plane</Name><Path>plane</Path></DataCategory><DataCategory uid="06DE08988C53"><Name>Taxi</Name><Path>taxi</Path></DataCategory><DataCategory uid="B1A64213FA9D"><Name>Train</Name><Path>train</Path></DataCategory></DataCategories></Children></DataCategoryResource></Resources>'))
    @root = AMEE::Data::Category.root(connection)
    @transport = @root.child('transport')
    @transport.path.should == "/transport"
    @transport.itemdef.should == nil
    @transport.full_path.should == "/data/transport"
    @transport.uid.should == "263FC0186834"
    @transport.children.size.should be(7)
    @transport.pager.should be_nil
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data/transport/plane/generic", {:itemsPerPage => 10}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path>/transport/plane/generic</Path><DataCategory created="2007-08-01 09:00:23.0" modified="2007-08-01 09:00:23.0" uid="FBA97B70DBDF"><Name>Generic</Name><Path>generic</Path><Environment uid="5F5887BCF726"/><DataCategory uid="6F3692D81CD9"><Name>Plane</Name><Path>plane</Path></DataCategory><ItemDefinition uid="441BF4BEA15B"/></DataCategory><Children><DataCategories/><DataItems><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="AD63A83B4D41"><kgCO2PerPassengerJourney>0</kgCO2PerPassengerJourney><type>domestic</type><label>domestic</label><size>-</size><path>AD63A83B4D41</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0.158</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="FFC7A05D54AD"><kgCO2PerPassengerJourney>73</kgCO2PerPassengerJourney><type>domestic</type><label>domestic, one way</label><size>one way</size><path>FFC7A05D54AD</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="F5498AD6FC75"><kgCO2PerPassengerJourney>146</kgCO2PerPassengerJourney><type>domestic</type><label>domestic, return</label><size>return</size><path>F5498AD6FC75</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="7D4220DF72F9"><kgCO2PerPassengerJourney>0</kgCO2PerPassengerJourney><type>long haul</type><label>long haul</label><size>-</size><path>7D4220DF72F9</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0.105</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="46117F6C0B7E"><kgCO2PerPassengerJourney>801</kgCO2PerPassengerJourney><type>long haul</type><label>long haul, one way</label><size>one way</size><path>46117F6C0B7E</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="96D538B1B246"><kgCO2PerPassengerJourney>1602</kgCO2PerPassengerJourney><type>long haul</type><label>long haul, return</label><size>return</size><path>96D538B1B246</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="9DA419052FDF"><kgCO2PerPassengerJourney>0</kgCO2PerPassengerJourney><type>short haul</type><label>short haul</label><size>-</size><path>9DA419052FDF</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0.13</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="84B4A14C7424"><kgCO2PerPassengerJourney>170</kgCO2PerPassengerJourney><type>short haul</type><label>short haul, one way</label><size>one way</size><path>84B4A14C7424</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="8DA1BEAA1013"><kgCO2PerPassengerJourney>340</kgCO2PerPassengerJourney><type>short haul</type><label>short haul, return</label><size>return</size><path>8DA1BEAA1013</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem></DataItems><Pager><Start>0</Start><From>1</From><To>9</To><Items>9</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>9</ItemsFound></Pager></Children></DataCategoryResource></Resources>'))
    @data = AMEE::Data::Category.get(connection, "/data/transport/plane/generic")
    @data.uid.should == "FBA97B70DBDF"
    @data.itemdef.should == "441BF4BEA15B"
    @data.items.size.should be(9)
    @data.items[0][:uid].should == "AD63A83B4D41"
    @data.items[0][:label].should == "domestic"
    @data.items[0][:path].should == "AD63A83B4D41"
    @data.items[0][:source].should == "DfT INAS Division, 29 March 2007"
    @data.pager.should_not be_nil
  end

  it "should be able to get the itemdef" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data/transport/plane/generic", {:itemsPerPage => 10}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path>/transport/plane/generic</Path><DataCategory created="2007-08-01 09:00:23.0" modified="2007-08-01 09:00:23.0" uid="FBA97B70DBDF"><Name>Generic</Name><Path>generic</Path><Environment uid="5F5887BCF726"/><DataCategory uid="6F3692D81CD9"><Name>Plane</Name><Path>plane</Path></DataCategory><ItemDefinition uid="441BF4BEA15B"/></DataCategory><Children><DataCategories/><DataItems><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="AD63A83B4D41"><kgCO2PerPassengerJourney>0</kgCO2PerPassengerJourney><type>domestic</type><label>domestic</label><size>-</size><path>AD63A83B4D41</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0.158</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="FFC7A05D54AD"><kgCO2PerPassengerJourney>73</kgCO2PerPassengerJourney><type>domestic</type><label>domestic, one way</label><size>one way</size><path>FFC7A05D54AD</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="F5498AD6FC75"><kgCO2PerPassengerJourney>146</kgCO2PerPassengerJourney><type>domestic</type><label>domestic, return</label><size>return</size><path>F5498AD6FC75</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="7D4220DF72F9"><kgCO2PerPassengerJourney>0</kgCO2PerPassengerJourney><type>long haul</type><label>long haul</label><size>-</size><path>7D4220DF72F9</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0.105</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="46117F6C0B7E"><kgCO2PerPassengerJourney>801</kgCO2PerPassengerJourney><type>long haul</type><label>long haul, one way</label><size>one way</size><path>46117F6C0B7E</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="96D538B1B246"><kgCO2PerPassengerJourney>1602</kgCO2PerPassengerJourney><type>long haul</type><label>long haul, return</label><size>return</size><path>96D538B1B246</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="9DA419052FDF"><kgCO2PerPassengerJourney>0</kgCO2PerPassengerJourney><type>short haul</type><label>short haul</label><size>-</size><path>9DA419052FDF</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0.13</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="84B4A14C7424"><kgCO2PerPassengerJourney>170</kgCO2PerPassengerJourney><type>short haul</type><label>short haul, one way</label><size>one way</size><path>84B4A14C7424</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="8DA1BEAA1013"><kgCO2PerPassengerJourney>340</kgCO2PerPassengerJourney><type>short haul</type><label>short haul, return</label><size>return</size><path>8DA1BEAA1013</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem></DataItems><Pager><Start>0</Start><From>1</From><To>9</To><Items>9</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>9</ItemsFound></Pager></Children></DataCategoryResource></Resources>'))
    connection.should_receive(:get).with("/definitions/itemDefinitions/441BF4BEA15B",{}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><ItemDefinitionResource><ItemDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="441BF4BEA15B"><Name>Plane Generic</Name><DrillDown>type,size</DrillDown><Environment uid="5F5887BCF726"/></ItemDefinition></ItemDefinitionResource></Resources>')).once
    @data = AMEE::Data::Category.get(connection, "/data/transport/plane/generic")
    @data.uid.should == "FBA97B70DBDF"
    @data.itemdef.should == "441BF4BEA15B"
    @itemdef=@data.item_definition
    @itemdef.uid.should =="441BF4BEA15B"
  end

  it "should fail gracefully with bad XML" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('data.xml').first(12)))
    lambda{AMEE::Data::Category.get(connection, "/data")}.should raise_error(REXML::ParseException)
  end

  it "should retry if bad XML is received first time" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(1)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('data.xml').first(12))).once
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('data.xml'))).once
    lambda{AMEE::Data::Category.get(connection, "/data")}.should_not raise_error
  end

  it "should fail gracefully with bad data in XML" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('empty.xml')))
    lambda{AMEE::Data::Category.get(connection, "/data")}.should raise_error(AMEE::BadData)
  end

  it "provides access to drilldown resource" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data/transport/car/generic", {:itemsPerPage => 10}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path>/transport/car/generic</Path><DataCategory created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path><Environment uid="5F5887BCF726"/><DataCategory uid="1D95119FB149"><Name>Car</Name><Path>car</Path></DataCategory><ItemDefinition uid="123C4A18B5D6"/></DataCategory><Children><DataCategories><DataCategory uid="417DD367E9AA"><Name>Electric</Name><Path>electric</Path></DataCategory></DataCategories><DataItems><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="4F6CBCEE95F7"><fuel>diesel</fuel><kgCO2PerKm>0.23</kgCO2PerKm><label>diesel, large</label><kgCO2PerKmUS>0.23</kgCO2PerKmUS><size>large</size><path>4F6CBCEE95F7</path><source>NAEI / Company Reporting Guidelines</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="7E2B2426C927"><fuel>diesel</fuel><kgCO2PerKm>0.163</kgCO2PerKm><label>diesel, medium</label><kgCO2PerKmUS>0.163</kgCO2PerKmUS><size>medium</size><path>7E2B2426C927</path><source>NAEI / Company Reporting Guidelines</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="57E6AC080BF4"><fuel>diesel</fuel><kgCO2PerKm>0.131</kgCO2PerKm><label>diesel, small</label><kgCO2PerKmUS>0.131</kgCO2PerKmUS><size>small</size><path>57E6AC080BF4</path><source>NAEI / Company Reporting Guidelines</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="CEA465039777"><fuel>petrol</fuel><kgCO2PerKm>0.257</kgCO2PerKm><label>petrol, large</label><kgCO2PerKmUS>0.349</kgCO2PerKmUS><size>large</size><path>CEA465039777</path><source>"UK NAEI / Company Reporting Guidelines; US EPA/dgen"</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="9A9E8852220B"><fuel>petrol</fuel><kgCO2PerKm>0.188</kgCO2PerKm><label>petrol, medium</label><kgCO2PerKmUS>0.27</kgCO2PerKmUS><size>medium</size><path>9A9E8852220B</path><source>"UK NAEI / Company Reporting Guidelines; US EPA/dgen"</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="66DB66447D2F"><fuel>petrol</fuel><kgCO2PerKm>0.159</kgCO2PerKm><label>petrol, small</label><kgCO2PerKmUS>0.224</kgCO2PerKmUS><size>small</size><path>66DB66447D2F</path><source>"UK NAEI / Company Reporting Guidelines; US EPA/dgen"</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="69A44DCA9845"><fuel>petrol hybrid</fuel><kgCO2PerKm>0.195</kgCO2PerKm><label>petrol hybrid, large</label><kgCO2PerKmUS>0.195</kgCO2PerKmUS><size>large</size><path>69A44DCA9845</path><source>VCA CO2 database is source of original gCO2/km data</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="7DC4C91CD8DA"><fuel>petrol hybrid</fuel><kgCO2PerKm>0.11</kgCO2PerKm><label>petrol hybrid, medium</label><kgCO2PerKmUS>0.11</kgCO2PerKmUS><size>medium</size><path>7DC4C91CD8DA</path><source>VCA CO2 database is source of original gCO2/km data</source></DataItem></DataItems><Pager><Start>0</Start><From>1</From><To>8</To><Items>8</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>8</ItemsFound></Pager></Children></DataCategoryResource></Resources>'))
    connection.should_receive(:get).with("/data/transport/car/generic/drill").and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><DrillDownResource><DataCategory uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path></DataCategory><ItemDefinition uid="123C4A18B5D6"/><Selections/><Choices><Name>fuel</Name><Choices><Choice><Name>diesel</Name><Value>diesel</Value></Choice><Choice><Name>petrol</Name><Value>petrol</Value></Choice><Choice><Name>petrol hybrid</Name><Value>petrol hybrid</Value></Choice></Choices></Choices></DrillDownResource></Resources>'))
    lambda{
      cat = AMEE::Data::Category.get(connection, "/data/transport/car/generic")
      cat.drill
    }.should_not raise_error
  end

end

describe AMEE::Data::Category, "with an authenticated JSON connection" do

  it "should provide access to root of Data API" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('data.json')))
    @root = AMEE::Data::Category.root(connection)
    @root.name.should == "Root"
    @root.path.should == ""
    @root.full_path.should == "/data"
    @root.uid.should == "CD310BEBAC52"
    @root.created.should == DateTime.new(2007,7,27,9,30,44)
    @root.modified.should == DateTime.new(2007,7,27,9,30,44)
    @root.children.size.should be(5)
    @root.children[0][:uid].should == "BBA3AC3E795E"
    @root.children[0][:name].should == "Home"
    @root.children[0][:path].should == "home"
    @root.pager.should be_nil
  end

  it "should provide access to child objects" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('data.json')))
    connection.should_receive(:get).with("/data/transport", {:itemsPerPage => 10}).and_return(flexmock(:body => '{"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","dataCategory":{"uid":"CD310BEBAC52","path":"","name":"Root"},"uid":"263FC0186834","environment":{"uid":"5F5887BCF726"},"path":"transport","name":"Transport"},"path":"/transport","children":{"pager":{},"dataCategories":[{"uid":"3C4705614170","path":"bus","name":"Bus"},{"uid":"1D95119FB149","path":"car","name":"Car"},{"uid":"83C4FAF4826A","path":"motorcycle","name":"Motorcycle"},{"uid":"AFB73A5D2E45","path":"Other","name":"Other"},{"uid":"6F3692D81CD9","path":"plane","name":"Plane"},{"uid":"06DE08988C53","path":"taxi","name":"Taxi"},{"uid":"B1A64213FA9D","path":"train","name":"Train"}],"dataItems":{}}}'))
    @root = AMEE::Data::Category.root(connection)
    @transport = @root.child('transport')
    @transport.path.should == "/transport"
    @transport.itemdef.should == nil
    @transport.full_path.should == "/data/transport"
    @transport.uid.should == "263FC0186834"
    @transport.children.size.should be(7)
    @transport.pager.should be_nil
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data/transport/plane/generic", {:itemsPerPage => 10}).and_return(flexmock(:body => '{"dataCategory":{"modified":"2007-08-01 09:00:23.0","created":"2007-08-01 09:00:23.0","itemDefinition":{"uid":"441BF4BEA15B"},"dataCategory":{"uid":"6F3692D81CD9","path":"plane","name":"Plane"},"uid":"FBA97B70DBDF","environment":{"uid":"5F5887BCF726"},"path":"generic","name":"Generic"},"path":"/transport/plane/generic","children":{"pager":{"to":9,"lastPage":1,"start":0,"nextPage":-1,"items":9,"itemsPerPage":10,"from":1,"previousPage":-1,"requestedPage":1,"currentPage":1,"itemsFound":9},"dataCategories":[],"dataItems":{"rows":[{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"domestic","label":"domestic","uid":"AD63A83B4D41","path":"AD63A83B4D41","size":"-","kgCO2PerPassengerJourney":"0","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0.158"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"domestic","label":"domestic, one way","uid":"FFC7A05D54AD","path":"FFC7A05D54AD","size":"one way","kgCO2PerPassengerJourney":"73","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"domestic","label":"domestic, return","uid":"F5498AD6FC75","path":"F5498AD6FC75","size":"return","kgCO2PerPassengerJourney":"146","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"long haul","label":"long haul","uid":"7D4220DF72F9","path":"7D4220DF72F9","size":"-","kgCO2PerPassengerJourney":"0","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0.105"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"long haul","label":"long haul, one way","uid":"46117F6C0B7E","path":"46117F6C0B7E","size":"one way","kgCO2PerPassengerJourney":"801","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"long haul","label":"long haul, return","uid":"96D538B1B246","path":"96D538B1B246","size":"return","kgCO2PerPassengerJourney":"1602","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"short haul","label":"short haul","uid":"9DA419052FDF","path":"9DA419052FDF","size":"-","kgCO2PerPassengerJourney":"0","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0.13"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"short haul","label":"short haul, one way","uid":"84B4A14C7424","path":"84B4A14C7424","size":"one way","kgCO2PerPassengerJourney":"170","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"short haul","label":"short haul, return","uid":"8DA1BEAA1013","path":"8DA1BEAA1013","size":"return","kgCO2PerPassengerJourney":"340","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"}],"label":"DataItems"}}}'))
    @data = AMEE::Data::Category.get(connection, "/data/transport/plane/generic")
    @data.uid.should == "FBA97B70DBDF"
    @data.itemdef.should == "441BF4BEA15B"
    @data.items.size.should be(9)
    @data.items[0][:uid].should == "AD63A83B4D41"
    @data.items[0][:label].should == "domestic"
    @data.items[0][:path].should == "AD63A83B4D41"
    @data.items[0][:source].should == "DfT INAS Division, 29 March 2007"
    @data.pager.should_not be_nil
  end

  it "should fail gracefully with bad JSON" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => "{"))
    lambda{AMEE::Data::Category.get(connection, "/data")}.should raise_error(JSON::ParserError)
  end

  it "should retry if bad JSON is received first time" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(1)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => "{")).once
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('data.json'))).once
    lambda{AMEE::Data::Category.get(connection, "/data")}.should_not raise_error
  end

  it "should fail gracefully with bad data in json" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_return(flexmock(:body => fixture('empty.json')))
    lambda{AMEE::Data::Category.get(connection, "/data")}.should raise_error(AMEE::BadData)
  end

end

describe AMEE::Data::Category, "with an authenticated connection" do

  it "should fail gracefully on other GET errors" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0)
    connection.should_receive(:get).with("/data", {:itemsPerPage => 10}).and_raise(Timeout::Error)
    lambda{AMEE::Data::Category.get(connection, "/data")}.should raise_error(Timeout::Error)
  end

end
