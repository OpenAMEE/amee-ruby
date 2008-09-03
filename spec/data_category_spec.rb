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
  
describe AMEE::Data::Category, "with an authenticated XML connection" do

  it "should provide access to root of Data API" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path/><DataCategory created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CD310BEBAC52"><Name>Root</Name><Path/><Environment uid="5F5887BCF726"/></DataCategory><Children><DataCategories><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><DataCategory uid="9E5362EAB0E7"><Name>Metadata</Name><Path>metadata</Path></DataCategory><DataCategory uid="6153F468BE05"><Name>Test</Name><Path>test</Path></DataCategory><DataCategory uid="263FC0186834"><Name>Transport</Name><Path>transport</Path></DataCategory><DataCategory uid="2957AE9B6E6B"><Name>User</Name><Path>user</Path></DataCategory></DataCategories></Children></DataCategoryResource></Resources>')
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
  end

  it "should provide access to child objects" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path/><DataCategory created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CD310BEBAC52"><Name>Root</Name><Path/><Environment uid="5F5887BCF726"/></DataCategory><Children><DataCategories><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><DataCategory uid="9E5362EAB0E7"><Name>Metadata</Name><Path>metadata</Path></DataCategory><DataCategory uid="6153F468BE05"><Name>Test</Name><Path>test</Path></DataCategory><DataCategory uid="263FC0186834"><Name>Transport</Name><Path>transport</Path></DataCategory><DataCategory uid="2957AE9B6E6B"><Name>User</Name><Path>user</Path></DataCategory></DataCategories></Children></DataCategoryResource></Resources>')
    connection.should_receive(:get).with("/data/transport").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path>/transport</Path><DataCategory created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="263FC0186834"><Name>Transport</Name><Path>transport</Path><Environment uid="5F5887BCF726"/><DataCategory uid="CD310BEBAC52"><Name>Root</Name><Path/></DataCategory></DataCategory><Children><DataCategories><DataCategory uid="3C4705614170"><Name>Bus</Name><Path>bus</Path></DataCategory><DataCategory uid="1D95119FB149"><Name>Car</Name><Path>car</Path></DataCategory><DataCategory uid="83C4FAF4826A"><Name>Motorcycle</Name><Path>motorcycle</Path></DataCategory><DataCategory uid="AFB73A5D2E45"><Name>Other</Name><Path>Other</Path></DataCategory><DataCategory uid="6F3692D81CD9"><Name>Plane</Name><Path>plane</Path></DataCategory><DataCategory uid="06DE08988C53"><Name>Taxi</Name><Path>taxi</Path></DataCategory><DataCategory uid="B1A64213FA9D"><Name>Train</Name><Path>train</Path></DataCategory></DataCategories></Children></DataCategoryResource></Resources>')
    @root = AMEE::Data::Category.root(connection)
    @transport = @root.child('transport')
    @transport.path.should == "/transport"
    @transport.full_path.should == "/data/transport"
    @transport.uid.should == "263FC0186834"
    @transport.children.size.should be(7)
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path>/transport/plane/generic</Path><DataCategory created="2007-08-01 09:00:23.0" modified="2007-08-01 09:00:23.0" uid="FBA97B70DBDF"><Name>Generic</Name><Path>generic</Path><Environment uid="5F5887BCF726"/><DataCategory uid="6F3692D81CD9"><Name>Plane</Name><Path>plane</Path></DataCategory><ItemDefinition uid="441BF4BEA15B"/></DataCategory><Children><DataCategories/><DataItems><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="AD63A83B4D41"><kgCO2PerPassengerJourney>0</kgCO2PerPassengerJourney><type>domestic</type><label>domestic</label><size>-</size><path>AD63A83B4D41</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0.158</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="FFC7A05D54AD"><kgCO2PerPassengerJourney>73</kgCO2PerPassengerJourney><type>domestic</type><label>domestic, one way</label><size>one way</size><path>FFC7A05D54AD</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="F5498AD6FC75"><kgCO2PerPassengerJourney>146</kgCO2PerPassengerJourney><type>domestic</type><label>domestic, return</label><size>return</size><path>F5498AD6FC75</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="7D4220DF72F9"><kgCO2PerPassengerJourney>0</kgCO2PerPassengerJourney><type>long haul</type><label>long haul</label><size>-</size><path>7D4220DF72F9</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0.105</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="46117F6C0B7E"><kgCO2PerPassengerJourney>801</kgCO2PerPassengerJourney><type>long haul</type><label>long haul, one way</label><size>one way</size><path>46117F6C0B7E</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="96D538B1B246"><kgCO2PerPassengerJourney>1602</kgCO2PerPassengerJourney><type>long haul</type><label>long haul, return</label><size>return</size><path>96D538B1B246</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="9DA419052FDF"><kgCO2PerPassengerJourney>0</kgCO2PerPassengerJourney><type>short haul</type><label>short haul</label><size>-</size><path>9DA419052FDF</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0.13</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="84B4A14C7424"><kgCO2PerPassengerJourney>170</kgCO2PerPassengerJourney><type>short haul</type><label>short haul, one way</label><size>one way</size><path>84B4A14C7424</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem><DataItem created="2007-08-01 09:00:41.0" modified="2007-08-01 09:00:41.0" uid="8DA1BEAA1013"><kgCO2PerPassengerJourney>340</kgCO2PerPassengerJourney><type>short haul</type><label>short haul, return</label><size>return</size><path>8DA1BEAA1013</path><source>DfT INAS Division, 29 March 2007</source><kgCO2PerPassengerKm>0</kgCO2PerPassengerKm></DataItem></DataItems><Pager><Start>0</Start><From>1</From><To>9</To><Items>9</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>9</ItemsFound></Pager></Children></DataCategoryResource></Resources>')
    @data = AMEE::Data::Category.get(connection, "/data/transport/plane/generic")
    @data.uid.should == "FBA97B70DBDF"
    @data.items.size.should be(9)
    @data.items[0][:uid].should == "AD63A83B4D41"
    @data.items[0][:label].should == "domestic"
    @data.items[0][:path].should == "AD63A83B4D41"    
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>')
    lambda{AMEE::Data::Category.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataCategory from XML data. Check that your URL is correct.")
  end

end

describe AMEE::Data::Category, "with an authenticated JSON connection" do

  it "should provide access to root of Data API" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('{"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","uid":"CD310BEBAC52","environment":{"uid":"5F5887BCF726"},"path":"","name":"Root"},"path":"","children":{"pager":{},"dataCategories":[{"uid":"BBA3AC3E795E","path":"home","name":"Home"},{"uid":"9E5362EAB0E7","path":"metadata","name":"Metadata"},{"uid":"6153F468BE05","path":"test","name":"Test"},{"uid":"263FC0186834","path":"transport","name":"Transport"},{"uid":"2957AE9B6E6B","path":"user","name":"User"}],"dataItems":{}}}')
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
  end

  it "should provide access to child objects" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('{"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","uid":"CD310BEBAC52","environment":{"uid":"5F5887BCF726"},"path":"","name":"Root"},"path":"","children":{"pager":{},"dataCategories":[{"uid":"BBA3AC3E795E","path":"home","name":"Home"},{"uid":"9E5362EAB0E7","path":"metadata","name":"Metadata"},{"uid":"6153F468BE05","path":"test","name":"Test"},{"uid":"263FC0186834","path":"transport","name":"Transport"},{"uid":"2957AE9B6E6B","path":"user","name":"User"}],"dataItems":{}}}')
    connection.should_receive(:get).with("/data/transport").and_return('{"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","dataCategory":{"uid":"CD310BEBAC52","path":"","name":"Root"},"uid":"263FC0186834","environment":{"uid":"5F5887BCF726"},"path":"transport","name":"Transport"},"path":"/transport","children":{"pager":{},"dataCategories":[{"uid":"3C4705614170","path":"bus","name":"Bus"},{"uid":"1D95119FB149","path":"car","name":"Car"},{"uid":"83C4FAF4826A","path":"motorcycle","name":"Motorcycle"},{"uid":"AFB73A5D2E45","path":"Other","name":"Other"},{"uid":"6F3692D81CD9","path":"plane","name":"Plane"},{"uid":"06DE08988C53","path":"taxi","name":"Taxi"},{"uid":"B1A64213FA9D","path":"train","name":"Train"}],"dataItems":{}}}')
    @root = AMEE::Data::Category.root(connection)
    @transport = @root.child('transport')
    @transport.path.should == "/transport"
    @transport.full_path.should == "/data/transport"
    @transport.uid.should == "263FC0186834"
    @transport.children.size.should be(7)
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/plane/generic").and_return('{"dataCategory":{"modified":"2007-08-01 09:00:23.0","created":"2007-08-01 09:00:23.0","itemDefinition":{"uid":"441BF4BEA15B"},"dataCategory":{"uid":"6F3692D81CD9","path":"plane","name":"Plane"},"uid":"FBA97B70DBDF","environment":{"uid":"5F5887BCF726"},"path":"generic","name":"Generic"},"path":"/transport/plane/generic","children":{"pager":{"to":9,"lastPage":1,"start":0,"nextPage":-1,"items":9,"itemsPerPage":10,"from":1,"previousPage":-1,"requestedPage":1,"currentPage":1,"itemsFound":9},"dataCategories":[],"dataItems":{"rows":[{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"domestic","label":"domestic","uid":"AD63A83B4D41","path":"AD63A83B4D41","size":"-","kgCO2PerPassengerJourney":"0","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0.158"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"domestic","label":"domestic, one way","uid":"FFC7A05D54AD","path":"FFC7A05D54AD","size":"one way","kgCO2PerPassengerJourney":"73","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"domestic","label":"domestic, return","uid":"F5498AD6FC75","path":"F5498AD6FC75","size":"return","kgCO2PerPassengerJourney":"146","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"long haul","label":"long haul","uid":"7D4220DF72F9","path":"7D4220DF72F9","size":"-","kgCO2PerPassengerJourney":"0","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0.105"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"long haul","label":"long haul, one way","uid":"46117F6C0B7E","path":"46117F6C0B7E","size":"one way","kgCO2PerPassengerJourney":"801","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"long haul","label":"long haul, return","uid":"96D538B1B246","path":"96D538B1B246","size":"return","kgCO2PerPassengerJourney":"1602","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"short haul","label":"short haul","uid":"9DA419052FDF","path":"9DA419052FDF","size":"-","kgCO2PerPassengerJourney":"0","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0.13"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"short haul","label":"short haul, one way","uid":"84B4A14C7424","path":"84B4A14C7424","size":"one way","kgCO2PerPassengerJourney":"170","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"},{"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","type":"short haul","label":"short haul, return","uid":"8DA1BEAA1013","path":"8DA1BEAA1013","size":"return","kgCO2PerPassengerJourney":"340","source":"DfT INAS Division, 29 March 2007","kgCO2PerPassengerKm":"0"}],"label":"DataItems"}}}')
    @data = AMEE::Data::Category.get(connection, "/data/transport/plane/generic")
    @data.uid.should == "FBA97B70DBDF"
    @data.items.size.should be(9)
    @data.items[0][:uid].should == "AD63A83B4D41"
    @data.items[0][:label].should == "domestic"
    @data.items[0][:path].should == "AD63A83B4D41"    
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_return('{}')
    lambda{AMEE::Data::Category.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataCategory from JSON data. Check that your URL is correct.")
  end

end

describe AMEE::Data::Category, "with an authenticated connection" do

  it "should fail gracefully on other GET errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data").and_raise("unidentified error")
    lambda{AMEE::Data::Category.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataCategory. Check that your URL is correct.")
  end

end
