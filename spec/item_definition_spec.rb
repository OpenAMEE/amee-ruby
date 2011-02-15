require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Admin::ItemDefinition do

  before(:each) do
    @item_definition = AMEE::Admin::ItemDefinition.new
  end

  it "should have common AMEE object properties" do
    @item_definition.is_a?(AMEE::Object).should be_true
  end

  it "should have a name" do
    @item_definition.should respond_to(:name)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @item_definition = AMEE::Admin::ItemDefinition.new(:uid => uid)
    @item_definition.uid.should == uid
  end

  it "can be created with hash of data" do
    name = "test"
    @item_definition = AMEE::Admin::ItemDefinition.new(:name => name)
    @item_definition.name.should == name
  end

end

describe AMEE::Admin::ItemDefinition, "with an authenticated connection" do

  it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><ItemDefinitionResource><ItemDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="BD88D30D1214"><Name>Bus Generic</Name><DrillDown>type</DrillDown><Environment uid="5F5887BCF726"/></ItemDefinition></ItemDefinitionResource></Resources>'))
    @data = AMEE::Admin::ItemDefinition.load(connection,"BD88D30D1214")
    @data.uid.should == "BD88D30D1214"
    @data.created.should == DateTime.new(2007,7,27,9,30,44)
    @data.modified.should == DateTime.new(2007,7,27,9,30,44)
    @data.name.should == "Bus Generic"
    @data.drill_downs.should == ["type"]
    @data.full_path.should == '/definitions/itemDefinitions/BD88D30D1214'
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214", {}).and_return(flexmock(:body => '{"itemDefinition":{"uid":"BD88D30D1214","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","name":"Bus Generic","drillDown":"type","modified":"2007-07-27 09:30:44.0"}}'))
    @data = AMEE::Admin::ItemDefinition.load(connection,"BD88D30D1214")
    @data.uid.should == "BD88D30D1214"
    @data.created.should == DateTime.new(2007,7,27,9,30,44)
    @data.modified.should == DateTime.new(2007,7,27,9,30,44)
    @data.name.should == "Bus Generic"
    @data.drill_downs.should == ["type"]
    @data.full_path.should == '/definitions/itemDefinitions/BD88D30D1214'
  end

  it "should be able to load an item value definition list" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><ItemDefinitionResource><ItemDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="BD88D30D1214"><Name>Bus Generic</Name><DrillDown>type</DrillDown><Environment uid="5F5887BCF726"/></ItemDefinition></ItemDefinitionResource></Resources>'))
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214/itemValueDefinitions", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources><ItemValueDefinitionsResource><Environment uid="5F5887BCF726"/><ItemDefinition uid="BD88D30D1214"/><ItemValueDefinitions><ItemValueDefinition uid="A8A212610A57"><Path>distancePerJourney</Path><Name>Distance per journey</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="D2AB505D2D91"><Path>type</Path><Name>Type</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>true</DrillDown></ItemValueDefinition><ItemValueDefinition uid="41EC337E5C79"><Path>numberOfJourneys</Path><Name>Number of journeys</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="9BAFC976044B"><Path>source</Path><Name>Source</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="9813267B616E"><Path>country</Path><Name>Country</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="263DE76AF8AA"><Path>kgCO2PerPassengerKmIE</Path><Name>kgCO2 Per Passenger Km IE</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="996AE5477B3F"><Name>kgCO2PerKm</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="F5550D71085F"><Path>kgCO2PerKmPassenger</Path><Name>kgCO2 Per Passenger Km</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="996AE5477B3F"><Name>kgCO2PerKm</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="FE166C7602BB"><Path>typicalJourneyDistance</Path><Name>Typical journey distance</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>false</FromProfile><FromData>true</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="2F76AB4E3C0F"><Path>journeyFrequency</Path><Name>Journey frequency</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="B0F02E544603"><Path>numberOfPassengers</Path><Name>Number of passengers</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="28D0B8C4F52A"><Path>useTypicalDistance</Path><Name>Use typical distance</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="6334117D28A0"><Path>distanceKmPerMonth</Path><Name>Distance Km Per Month</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="B691497F1CF2"><Name>kM</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><PerUnit>month</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="98EA75911467"><Path>distancePerJourney</Path><Name>Distance per journey</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="584BEA802996"><Path>isReturn</Path><Name>Is return</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition><ItemValueDefinition uid="6CBF739E12F0"><Path>distance</Path><Name>Distance</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>km</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValueDefinitions></ItemValueDefinitionsResource></Resources>')).once
    @data = AMEE::Admin::ItemDefinition.load(connection,"BD88D30D1214")
    @data.uid.should == "BD88D30D1214"
    @list=@data.item_value_definition_list
    @list.length.should==15
    @list.first.uid.should=='A8A212610A57'
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:get).with("/admin", {}).and_return(flexmock(:body => xml))
    lambda{AMEE::Admin::ItemDefinition.get(connection, "/admin")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    json = '{}'
    connection.should_receive(:get).with("/admin", {}).and_return(flexmock(:body => json))
    lambda{AMEE::Admin::ItemDefinition.get(connection, "/admin")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/admin", {}).and_raise("unidentified error")
    lambda{AMEE::Admin::ItemDefinition.get(connection, "/admin")}.should raise_error(AMEE::BadData)
  end

end

DefinitionsListResponse=<<HERE
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<Resources>
<ItemDefinitionsResource>
  <ItemDefinitions>
    <ItemDefinition uid="2169991DE821">
      <Name>AAA Car Generic</Name>
      <DrillDown>fuel,size</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="18CB59F9EC2D">
      <Name>AAA Units test</Name>
      <DrillDown>type</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="76C56F7DF49A">
      <Name>AAAA1234Test</Name>
      <DrillDown/>
    </ItemDefinition>
    <ItemDefinition uid="CF344E20E9AC">
      <Name>AAATipTest</Name>
      <DrillDown>question</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="70BCD634D0A4">
      <Name>ActOnCO2 Action</Name>
      <DrillDown>type</DrillDown></ItemDefinition>
    <ItemDefinition uid="62058B6FD778">
      <Name>ActOnCO2 Metadata</Name>
      <DrillDown>type</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="D3351CDC11C8">
      <Name>ADigTest</Name>
      <DrillDown/></ItemDefinition>
    <ItemDefinition uid="A02807E44CA3">
      <Name>Adipic Acid N2O emissions</Name>
      <DrillDown>abatementTechnology</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="B910141B00DB">
      <Name>AJC ID TEST</Name>
      <DrillDown>type</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="4660BD4FCF97">
      <Name>Aluminium Production: Alternative (no anode data)</Name>
      <DrillDown>type</DrillDown>
    </ItemDefinition></ItemDefinitions>
    <Pager>
        <Start>0</Start>
        <From>1</From>
        <To>10</To>
        <Items>10</Items>
        <CurrentPage>1</CurrentPage>
        <RequestedPage>1</RequestedPage>
        <NextPage>-1</NextPage>
        <PreviousPage>-1</PreviousPage>
        <LastPage>1</LastPage>
        <ItemsPerPage>10</ItemsPerPage>
        <ItemsFound>10</ItemsFound>
    </Pager>
  </ItemDefinitionsResource>
</Resources>
HERE

DefinitionsListResponsePage1=<<HERE
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<Resources>
<ItemDefinitionsResource>
  <ItemDefinitions>
    <ItemDefinition uid="2169991DE821">
      <Name>AAA Car Generic</Name>
      <DrillDown>fuel,size</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="18CB59F9EC2D">
      <Name>AAA Units test</Name>
      <DrillDown>type</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="76C56F7DF49A">
      <Name>AAAA1234Test</Name>
      <DrillDown/>
    </ItemDefinition>
    <ItemDefinition uid="CF344E20E9AC">
      <Name>AAATipTest</Name>
      <DrillDown>question</DrillDown>
    </ItemDefinition></ItemDefinitions>
    <Pager>
        <Start>0</Start>
        <From>1</From>
        <To>4</To>
        <Items>10</Items>
        <CurrentPage>1</CurrentPage>
        <RequestedPage>1</RequestedPage>
        <NextPage>2</NextPage>
        <PreviousPage>-1</PreviousPage>
        <LastPage>3</LastPage>
        <ItemsPerPage>4</ItemsPerPage>
        <ItemsFound>4</ItemsFound>
    </Pager>
  </ItemDefinitionsResource>
</Resources>
HERE
DefinitionsListResponsePage2=<<HERE
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<Resources>
<ItemDefinitionsResource>
  <ItemDefinitions>
    <ItemDefinition uid="70BCD634D0A4">
      <Name>ActOnCO2 Action</Name>
      <DrillDown>type</DrillDown></ItemDefinition>
    <ItemDefinition uid="62058B6FD778">
      <Name>ActOnCO2 Metadata</Name>
      <DrillDown>type</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="D3351CDC11C8">
      <Name>ADigTest</Name>
      <DrillDown/></ItemDefinition>
    <ItemDefinition uid="A02807E44CA3">
      <Name>Adipic Acid N2O emissions</Name>
      <DrillDown>abatementTechnology</DrillDown>
    </ItemDefinition></ItemDefinitions>
    <Pager>
        <Start>4</Start>
        <From>5</From>
        <To>8</To>
        <Items>10</Items>
        <CurrentPage>2</CurrentPage>
        <RequestedPage>2</RequestedPage>
        <NextPage>3</NextPage>
        <PreviousPage>1</PreviousPage>
        <LastPage>3</LastPage>
        <ItemsPerPage>4</ItemsPerPage>
        <ItemsFound>4</ItemsFound>
    </Pager>
  </ItemDefinitionsResource>
</Resources>
HERE
DefinitionsListResponsePage3=<<HERE
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<Resources>
<ItemDefinitionsResource>
  <ItemDefinitions>
    <ItemDefinition uid="B910141B00DB">
      <Name>AJC ID TEST</Name>
      <DrillDown>type</DrillDown>
    </ItemDefinition>
    <ItemDefinition uid="4660BD4FCF97">
      <Name>Aluminium Production: Alternative (no anode data)</Name>
      <DrillDown>type</DrillDown>
    </ItemDefinition>
    </ItemDefinitions>
    <Pager>
        <Start>8</Start>
        <From>9</From>
        <To>10</To>
        <Items>10</Items>
        <CurrentPage>3</CurrentPage>
        <RequestedPage>3</RequestedPage>
        <NextPage>-1</NextPage>
        <PreviousPage>2</PreviousPage>
        <LastPage>3</LastPage>
        <ItemsPerPage>4</ItemsPerPage>
        <ItemsFound>2</ItemsFound>
    </Pager>
  </ItemDefinitionsResource>
</Resources>
HERE

describe AMEE::Admin::ItemDefinitionList do
  it "Should parse a single page" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:get).with("/definitions/itemDefinitions",{}).once.
      and_return flexmock(:body =>DefinitionsListResponse)
    @list=AMEE::Admin::ItemDefinitionList.new(connection)
    @list.first.should be_a AMEE::Admin::ItemDefinition
    @list.first.uid.should == "2169991DE821"
    @list.first.name.should == "AAA Car Generic"
    @list.size.should==10
  end

  it "Should retry on parse failures" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(2).once
    connection.should_receive(:get).with("/definitions/itemDefinitions",{}).twice.
      and_return flexmock(:body =>DefinitionsListResponse.first(12))
    connection.should_receive(:expire).with("/definitions/itemDefinitions").times(2)
    connection.should_receive(:get).with("/definitions/itemDefinitions",{}).once.
      and_return flexmock(:body =>DefinitionsListResponse)
    @list=AMEE::Admin::ItemDefinitionList.new(connection)
    @list.first.should be_a AMEE::Admin::ItemDefinition
    @list.first.uid.should == "2169991DE821"
    @list.first.name.should == "AAA Car Generic"
    @list.size.should==10
  end

  it "Should retry on parse failures and bubble up failure if never successful" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(2).once
    connection.should_receive(:get).with("/definitions/itemDefinitions",{}).times(3).
      and_return flexmock(:body =>DefinitionsListResponse.first(12))
    connection.should_receive(:expire).with("/definitions/itemDefinitions").times(3)
    lambda {
      AMEE::Admin::ItemDefinitionList.new(connection)
    }.should raise_error(Nokogiri::XML::SyntaxError)
  end
  it "Should parse multiple pages" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).times(3)
    connection.should_receive(:get).with("/definitions/itemDefinitions",{}).
      once.
      and_return flexmock(:body =>DefinitionsListResponsePage1)
    connection.should_receive(:get).with("/definitions/itemDefinitions",
      {:page=>2}).once.
      and_return flexmock(:body =>DefinitionsListResponsePage2)
    connection.should_receive(:get).with("/definitions/itemDefinitions",
      {:page=>3}).once.
      and_return flexmock(:body =>DefinitionsListResponsePage3)
    @list=AMEE::Admin::ItemDefinitionList.new(connection)
    @list.first.should be_a AMEE::Admin::ItemDefinition
    @list.first.uid.should == "2169991DE821"
    @list.first.name.should == "AAA Car Generic"
    @list[4].should be_a AMEE::Admin::ItemDefinition
    @list[4].uid.should == "70BCD634D0A4"
    @list[4].name.should == "ActOnCO2 Action"
    @list.size.should==10
  end
end