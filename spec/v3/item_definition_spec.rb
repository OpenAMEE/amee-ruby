# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'

describe AMEE::Admin::ItemDefinition do

  before(:each) do
    @item_definition = AMEE::Admin::ItemDefinition.new
  end

  it "should provide a usages array" do
    @item_definition.usages.should == []
  end

end

describe AMEE::Admin::ItemDefinition, "with an authenticated v3 connection" do

  it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/472D78F6584E;full", {}).and_return(fixture('itemdef.xml'))
    @data = AMEE::Admin::ItemDefinition.load(connection,"472D78F6584E")
    @data.uid.should == "472D78F6584E"
    @data.created.should == DateTime.new(2009,8,31,12,41,18)
    @data.modified.should == DateTime.new(2010,8,13,14,54,33)
    @data.name.should == "Power Stations And Stuff"
    @data.drill_downs.should == %w{state county metroArea city zipCode plantName powWowWow}
    @data.usages.should == ['usageOne', 'usageThree', 'usageOther']
    @data.algorithms['default'].should eql "D4E4779CA7AB"
  end

  it "should parse XML correctly if there are no usages or algorithms" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/472D78F6584E;full", {}).and_return(fixture('itemdef_no_usages.xml'))
    @data = AMEE::Admin::ItemDefinition.load(connection,"472D78F6584E")
    @data.usages.should == []
    @data.algorithms.should == {}
  end

  it "should parse XML correctly if there is just one usage" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/472D78F6584E;full", {}).and_return(fixture('itemdef_one_usage.xml'))
    @data = AMEE::Admin::ItemDefinition.load(connection,"472D78F6584E")
    @data.usages.should == ['usageOne']
  end

  it "should be able to load an item value definition list" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/472D78F6584E;full", {}).and_return(fixture('itemdef.xml')).once
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/472D78F6584E/values;full", {:resultStart => 0, :resultLimit => 10}).and_return(fixture('ivdlist.xml')).once
    @data = AMEE::Admin::ItemDefinition.load(connection,"472D78F6584E")
    @data.uid.should == "472D78F6584E"
    @list=@data.item_value_definition_list
    @list.length.should==29
    @list.first.uid.should=='C531CA64DD72'
    @list.first.name.should eql 'Past carbon intensity'
    @list.first.path.should eql 'pastIntensity'
    @list.first.meta.wikidoc.should eql 'wikidoc'
    @list.first.valuetype.should eql 'DECIMAL'
    @list.first.compulsory?('usageOne').should be_true
    @list.first.forbidden?('usageTwo').should be_true
    @list.first.default.should eql 42.0
    @list.first.choices.should eql ['foo','bar']
    @list.first.unit.should == 'kg'
    @list.first.perunit.should == 'MWh'
    @list.first.profile?.should be_false
    @list.first.drill?.should be_false
    @list.first.data?.should be_true
    @list.first.versions.should == ['1.0', '2.0']
    @list[1].versions.should == ['2.0']
    @list[1].optional?('usageOne').should be_true
    @list[1].ignored?('usageTwo').should be_true
    @list[1].default.should be_nil
    @list.last.uid.should=='2B0A0E540D4C'
  end
  
  
  it "should be able to load an item value definition list with only one usage" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/B4DA9E4AD5F2;full", {}).and_return(fixture('itemdef_B4DA9E4AD5F2.xml')).once
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/B4DA9E4AD5F2/values;full", {:resultStart => 0, :resultLimit => 10}).and_return(fixture('ivdlist_one_usage.xml')).once
    @data = AMEE::Admin::ItemDefinition.load(connection,"B4DA9E4AD5F2")
    @data.uid.should == "B4DA9E4AD5F2"
    @list=@data.item_value_definition_list
    @list.first.ignored?('default').should be_true
    @list.first.compulsory?('default').should be_false
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources>'
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/472D78F6584E;full", {}).and_return(xml)
    lambda{AMEE::Admin::ItemDefinition.load(connection, "472D78F6584E")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/472D78F6584E;full", {}).and_raise("unidentified error")
    lambda{AMEE::Admin::ItemDefinition.load(connection, "472D78F6584E")}.should raise_error(AMEE::BadData)
  end

  it "should support updating" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/472D78F6584E;full", {}).and_return('<?xml version="1.0" encoding="UTF-8" standalone="no"?><Representation><ItemDefinition created="2009-08-31T12:41:18Z" modified="2010-08-13T14:54:33Z" status="ACTIVE" uid="472D78F6584E"><Name>Power Stations And Stuff</Name><DrillDown>state,county,metroArea,city,zipCode,plantName,powWowWow</DrillDown><Usages><Usage present="true"><Name>usageOne</Name></Usage><Usage present="true"><Name>usageThree</Name></Usage><Usage present="false"><Name>usageOther</Name></Usage></Usages></ItemDefinition><Status>OK</Status><Version>#{AMEE::Connection.api_version}.0</Version></Representation>').once
    connection.should_receive(:v3_put).with("/#{AMEE::Connection.api_version}/definitions/472D78F6584E", :usages => 'usageOther,usageThree,usageOne', :name => 'Power Stations And Stuff').once
    @data = AMEE::Admin::ItemDefinition.load(connection,"472D78F6584E")
    @data.usages.should == ['usageOne', 'usageThree', 'usageOther']
    @data.usages.reverse!
    @data.save!
  end

end

# Following is copied here to make sure that v2 list fetch still work when v3 stuff is added.
# Copied wholesale from v2 version

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
      and_return flexmock(:body =>DefinitionsListResponse[0,12])
    connection.should_receive(:expire).with("/definitions/itemDefinitions").twice
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
      and_return flexmock(:body =>DefinitionsListResponse[0,12])
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