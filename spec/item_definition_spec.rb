# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

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
    connection.should_receive(:v3_get).with("/3.3/definitions/BD88D30D1214;full", {}).and_return(fixture('BD88D30D1214.xml'))
    @data = AMEE::Admin::ItemDefinition.load(connection,"BD88D30D1214")
    @data.uid.should == "BD88D30D1214"
    @data.created.should == DateTime.new(2007,7,27,7,30,44)
    @data.modified.should == DateTime.new(2011,2,16,8,40,06)
    @data.name.should == "Bus Generic"
    @data.drill_downs.should == ["type"]
    @data.full_path.should == '/definitions/itemDefinitions/BD88D30D1214'
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).with("/3.3/definitions/BD88D30D1214;full", {}).and_return(fixture('BD88D30D1214.xml'))
    @data = AMEE::Admin::ItemDefinition.load(connection,"BD88D30D1214")
    @data.uid.should == "BD88D30D1214"
    @data.created.should == DateTime.new(2007,7,27,7,30,44)
    @data.modified.should == DateTime.new(2011,2,16,8,40,06)
    @data.name.should == "Bus Generic"
    @data.drill_downs.should == ["type"]
    @data.full_path.should == '/definitions/itemDefinitions/BD88D30D1214'
  end

  it "should be able to load an item value definition list" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).with("/3.3/definitions/BD88D30D1214;full", {}).and_return(fixture('BD88D30D1214.xml'))
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:v3_get).with("/3.3/definitions/BD88D30D1214/values;full", {:resultStart=>0, :resultLimit=>10}).and_return(fixture('ivdlist_BD88D30D1214.xml')).once
    @data = AMEE::Admin::ItemDefinition.load(connection,"BD88D30D1214")
    @data.uid.should == "BD88D30D1214"
    @list=@data.item_value_definition_list
    @list.length.should==15
    @list.first.uid.should=='9813267B616E'
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