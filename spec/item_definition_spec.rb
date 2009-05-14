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
    @data = AMEE::Admin::ItemDefinition.get(connection, "/definitions/itemDefinitions/BD88D30D1214")
    @data.uid.should == "BD88D30D1214"
    @data.created.should == DateTime.new(2007,7,27,9,30,44)
    @data.modified.should == DateTime.new(2007,7,27,9,30,44)
    @data.name.should == "Bus Generic"
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/definitions/itemDefinitions/BD88D30D1214", {}).and_return(flexmock(:body => '{"itemDefinition":{"uid":"BD88D30D1214","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","name":"Bus Generic","drillDown":"type","modified":"2007-07-27 09:30:44.0"}}'))
    @data = AMEE::Admin::ItemDefinition.get(connection, "/definitions/itemDefinitions/BD88D30D1214")
    @data.uid.should == "BD88D30D1214"
    @data.created.should == DateTime.new(2007,7,27,9,30,44)
    @data.modified.should == DateTime.new(2007,7,27,9,30,44)
    @data.name.should == "Bus Generic"
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/admin", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'))
    lambda{AMEE::Admin::ItemDefinition.get(connection, "/admin")}.should raise_error(AMEE::BadData, "Couldn't load ItemDefinition from XML. Check that your URL is correct.")
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/admin", {}).and_return(flexmock(:body => '{}'))
    lambda{AMEE::Admin::ItemDefinition.get(connection, "/admin")}.should raise_error(AMEE::BadData, "Couldn't load ItemDefinition from JSON. Check that your URL is correct.")
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/admin", {}).and_raise("unidentified error")
    lambda{AMEE::Admin::ItemDefinition.get(connection, "/admin")}.should raise_error(AMEE::BadData, "Couldn't load ItemDefinition. Check that your URL is correct.")
  end

end