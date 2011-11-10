# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'

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
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/BD88D30D1214/values;full", {:resultStart=>0, :resultLimit=>10}).and_return(fixture('ivdlist_BD88D30D1214.xml')).once
    @data = AMEE::Admin::ItemValueDefinitionList.new(connection,"BD88D30D1214")
    @data.length.should==15
    @data.first.uid.should=='9813267B616E'
    @data.first.name.should == "Country"
    @data.first.path.should == "country"
    @data.first.unit.should == nil
    @data.first.perunit.should == nil
    @data.first.profile?.should == true
    @data.first.drill?.should == false
    @data.first.data?.should == false
  end

   it "should apply block filter correctly" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/BD88D30D1214/values;full", {:resultStart=>0, :resultLimit=>10}).and_return(fixture('ivdlist_BD88D30D1214.xml')).once
    @data = AMEE::Admin::ItemValueDefinitionList.new(connection,"BD88D30D1214") do |x|
      x.uid == 'A8A212610A57' ? x : nil
    end
    #@data.length.should==1
    @data.first.uid.should=='A8A212610A57'
    @data.first.name.should == "Distance per journey"
    @data.first.path.should == "distancePerJourney"
    @data.first.unit.should == "km"
    @data.first.perunit.should == nil
    @data.first.profile?.should == true
    @data.first.drill?.should == false
    @data.first.data?.should == false
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/BD88D30D1214/values;full", {:resultStart=>0, :resultLimit=>10}).and_return(fixture('ivdlist_BD88D30D1214.xml')).once
    @data = AMEE::Admin::ItemValueDefinitionList.new(connection,"BD88D30D1214")
    @data.length.should==15
    @data.first.uid.should=='9813267B616E'
    @data.first.name.should == "Country"
    @data.first.path.should == "country"
    @data.first.unit.should == nil
    @data.first.perunit.should == nil
    @data.first.profile?.should == true
    @data.first.drill?.should == false
    @data.first.data?.should == false
  end

  it "should fail gracefully with incorrect XML data" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/BD88D30D1214/values;full", {:resultStart=>0, :resultLimit=>10}).and_return(xml)
    connection.should_receive(:expire).with("/#{AMEE::Connection.api_version}/definitions/BD88D30D1214/values;full").once
    lambda{AMEE::Admin::ItemValueDefinitionList.new(connection, "BD88D30D1214")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    json = '{}'
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/BD88D30D1214/values;full", {:resultStart=>0, :resultLimit=>10}).and_return(json)
    connection.should_receive(:expire).with("/#{AMEE::Connection.api_version}/definitions/BD88D30D1214/values;full").once
    lambda{AMEE::Admin::ItemValueDefinitionList.new(connection, "BD88D30D1214")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:v3_get).with("/#{AMEE::Connection.api_version}/definitions/BD88D30D1214/values;full", {:resultStart=>0, :resultLimit=>10}).and_raise(Timeout::Error)
    lambda{AMEE::Admin::ItemValueDefinitionList.new(connection, "BD88D30D1214")}.should raise_error(Timeout::Error)
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