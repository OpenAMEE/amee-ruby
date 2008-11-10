require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Data::DrillDown do
  
  before(:each) do
    @drill = AMEE::Data::DrillDown.new
  end
  
  it "should have common AMEE object properties" do
    @drill.is_a?(AMEE::Data::Object).should be_true
  end
  
  it "should have choices" do
    @drill.should respond_to(:choices)
  end

  it "should have a choice name" do
    @drill.should respond_to(:choice_name)
  end

  it "should have selections" do
    @drill.should respond_to(:selections)
  end

  it "provides access to data item uid" do
    @drill.should respond_to(:data_item_uid)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @drill = AMEE::Data::DrillDown.new(:uid => uid)
    @drill.uid.should == uid
  end

  it "can be created with hash of data" do
    choices = ["one", "two"]
    @drill = AMEE::Data::DrillDown.new(:choices => choices)
    @drill.choices.should == choices
  end
 
end
  
describe AMEE::Data::DrillDown, "with an authenticated XML connection" do

  it "loads drilldown resource" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/car/generic/drill?fuel=diesel").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DrillDownResource><DataCategory uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path></DataCategory><ItemDefinition uid="123C4A18B5D6"/><Selections><Choice><Name>fuel</Name><Value>diesel</Value></Choice></Selections><Choices><Name>size</Name><Choices><Choice><Name>large</Name><Value>large</Value></Choice><Choice><Name>medium</Name><Value>medium</Value></Choice><Choice><Name>small</Name><Value>small</Value></Choice></Choices></Choices></DrillDownResource></Resources>')
    drill = AMEE::Data::DrillDown.get(connection, "/data/transport/car/generic/drill?fuel=diesel")
    drill.choice_name.should == "size"
    drill.choices.size.should be(3)
    drill.choices[0].should == "large"
    drill.choices[1].should == "medium"
    drill.choices[2].should == "small"
    drill.selections.size.should be(1)
    drill.selections['fuel'].should == 'diesel'
    drill.data_item_uid.should be_nil
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/car/generic/drill?fuel=diesel").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>')
    lambda{AMEE::Data::DrillDown.get(connection, "/data/transport/car/generic/drill?fuel=diesel")}.should raise_error(AMEE::BadData, "Couldn't load DrillDown resource from XML data. Check that your URL is correct.")
  end

  it "provides simple access to uid" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/car/generic/drill?fuel=diesel&size=large").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DrillDownResource><DataCategory uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path></DataCategory><ItemDefinition uid="123C4A18B5D6"/><Selections><Choice><Name>fuel</Name><Value>diesel</Value></Choice><Choice><Name>size</Name><Value>large</Value></Choice></Selections><Choices><Name>uid</Name><Choices><Choice><Name>4F6CBCEE95F7</Name><Value>4F6CBCEE95F7</Value></Choice></Choices></Choices></DrillDownResource></Resources>')
    drill = AMEE::Data::DrillDown.get(connection, "/data/transport/car/generic/drill?fuel=diesel&size=large")
    drill.choice_name.should == "uid"
    drill.choices.size.should be(1)
    drill.selections.size.should be(2)
    drill.data_item_uid.should == "4F6CBCEE95F7"
  end

end

describe AMEE::Data::DrillDown, "with an authenticated JSON connection" do

  it "loads drilldown resource" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/car/generic/drill?fuel=diesel").and_return('{"itemDefinition":{"uid":"123C4A18B5D6"},"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","itemDefinition":{"uid":"123C4A18B5D6"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"87E55DA88017","environment":{"uid":"5F5887BCF726"},"path":"generic","name":"Generic"},"selections":[{"value":"diesel","name":"fuel"}],"choices":{"choices":[{"value":"large","name":"large"},{"value":"medium","name":"medium"},{"value":"small","name":"small"}],"name":"size"}}')
    drill = AMEE::Data::DrillDown.get(connection, "/data/transport/car/generic/drill?fuel=diesel")
    drill.choice_name.should == "size"
    drill.choices.size.should be(3)
    drill.choices[0].should == "large"
    drill.choices[1].should == "medium"
    drill.choices[2].should == "small"
    drill.selections.size.should be(1)
    drill.selections['fuel'].should == 'diesel'
    drill.data_item_uid.should be_nil
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/car/generic/drill?fuel=diesel").and_return('{}')
    lambda{AMEE::Data::DrillDown.get(connection, "/data/transport/car/generic/drill?fuel=diesel")}.should raise_error(AMEE::BadData, "Couldn't load DrillDown resource from JSON data. Check that your URL is correct.")
  end

  it "provides simple access to uid" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/car/generic/drill?fuel=diesel&size=large").and_return('{"itemDefinition":{"uid":"123C4A18B5D6"},"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","itemDefinition":{"uid":"123C4A18B5D6"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"87E55DA88017","environment":{"uid":"5F5887BCF726"},"path":"generic","name":"Generic"},"selections":[{"value":"diesel","name":"fuel"},{"value":"large","name":"size"}],"choices":{"choices":[{"value":"4F6CBCEE95F7","name":"4F6CBCEE95F7"}],"name":"uid"}}')
    drill = AMEE::Data::DrillDown.get(connection, "/data/transport/car/generic/drill?fuel=diesel&size=large")
    drill.choice_name.should == "uid"
    drill.choices.size.should be(1)
    drill.selections.size.should be(2)
    drill.data_item_uid.should == "4F6CBCEE95F7"
  end

end

describe AMEE::Data::DrillDown, "with data" do

  it "should fail gracefully on other GET errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/car/generic/drill?fuel=diesel").and_raise("unidentified error")
    lambda{AMEE::Data::DrillDown.get(connection, "/data/transport/car/generic/drill?fuel=diesel")}.should raise_error(AMEE::BadData, "Couldn't load DrillDown resource. Check that your URL is correct (/data/transport/car/generic/drill?fuel=diesel).")
  end

  it "enables drilling down through the levels" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data/transport/car/generic", {:itemsPerPage => 10}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DataCategoryResource><Path>/transport/car/generic</Path><DataCategory created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path><Environment uid="5F5887BCF726"/><DataCategory uid="1D95119FB149"><Name>Car</Name><Path>car</Path></DataCategory><ItemDefinition uid="123C4A18B5D6"/></DataCategory><Children><DataCategories><DataCategory uid="417DD367E9AA"><Name>Electric</Name><Path>electric</Path></DataCategory></DataCategories><DataItems><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="4F6CBCEE95F7"><fuel>diesel</fuel><kgCO2PerKm>0.23</kgCO2PerKm><label>diesel, large</label><kgCO2PerKmUS>0.23</kgCO2PerKmUS><size>large</size><path>4F6CBCEE95F7</path><source>NAEI / Company Reporting Guidelines</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="7E2B2426C927"><fuel>diesel</fuel><kgCO2PerKm>0.163</kgCO2PerKm><label>diesel, medium</label><kgCO2PerKmUS>0.163</kgCO2PerKmUS><size>medium</size><path>7E2B2426C927</path><source>NAEI / Company Reporting Guidelines</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="57E6AC080BF4"><fuel>diesel</fuel><kgCO2PerKm>0.131</kgCO2PerKm><label>diesel, small</label><kgCO2PerKmUS>0.131</kgCO2PerKmUS><size>small</size><path>57E6AC080BF4</path><source>NAEI / Company Reporting Guidelines</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="CEA465039777"><fuel>petrol</fuel><kgCO2PerKm>0.257</kgCO2PerKm><label>petrol, large</label><kgCO2PerKmUS>0.349</kgCO2PerKmUS><size>large</size><path>CEA465039777</path><source>"UK NAEI / Company Reporting Guidelines; US EPA/dgen"</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="9A9E8852220B"><fuel>petrol</fuel><kgCO2PerKm>0.188</kgCO2PerKm><label>petrol, medium</label><kgCO2PerKmUS>0.27</kgCO2PerKmUS><size>medium</size><path>9A9E8852220B</path><source>"UK NAEI / Company Reporting Guidelines; US EPA/dgen"</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="66DB66447D2F"><fuel>petrol</fuel><kgCO2PerKm>0.159</kgCO2PerKm><label>petrol, small</label><kgCO2PerKmUS>0.224</kgCO2PerKmUS><size>small</size><path>66DB66447D2F</path><source>"UK NAEI / Company Reporting Guidelines; US EPA/dgen"</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="69A44DCA9845"><fuel>petrol hybrid</fuel><kgCO2PerKm>0.195</kgCO2PerKm><label>petrol hybrid, large</label><kgCO2PerKmUS>0.195</kgCO2PerKmUS><size>large</size><path>69A44DCA9845</path><source>VCA CO2 database is source of original gCO2/km data</source></DataItem><DataItem created="2007-07-27 11:04:57.0" modified="2007-07-27 11:04:57.0" uid="7DC4C91CD8DA"><fuel>petrol hybrid</fuel><kgCO2PerKm>0.11</kgCO2PerKm><label>petrol hybrid, medium</label><kgCO2PerKmUS>0.11</kgCO2PerKmUS><size>medium</size><path>7DC4C91CD8DA</path><source>VCA CO2 database is source of original gCO2/km data</source></DataItem></DataItems><Pager><Start>0</Start><From>1</From><To>8</To><Items>8</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>8</ItemsFound></Pager></Children></DataCategoryResource></Resources>')
    connection.should_receive(:get).with("/data/transport/car/generic/drill").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DrillDownResource><DataCategory uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path></DataCategory><ItemDefinition uid="123C4A18B5D6"/><Selections/><Choices><Name>fuel</Name><Choices><Choice><Name>diesel</Name><Value>diesel</Value></Choice><Choice><Name>petrol</Name><Value>petrol</Value></Choice><Choice><Name>petrol hybrid</Name><Value>petrol hybrid</Value></Choice></Choices></Choices></DrillDownResource></Resources>')
    connection.should_receive(:get).with("/data/transport/car/generic/drill?fuel=diesel").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DrillDownResource><DataCategory uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path></DataCategory><ItemDefinition uid="123C4A18B5D6"/><Selections><Choice><Name>fuel</Name><Value>diesel</Value></Choice></Selections><Choices><Name>size</Name><Choices><Choice><Name>large</Name><Value>large</Value></Choice><Choice><Name>medium</Name><Value>medium</Value></Choice><Choice><Name>small</Name><Value>small</Value></Choice></Choices></Choices></DrillDownResource></Resources>')
    connection.should_receive(:get).with("/data/transport/car/generic/drill?fuel=diesel&size=large").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><DrillDownResource><DataCategory uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path></DataCategory><ItemDefinition uid="123C4A18B5D6"/><Selections><Choice><Name>fuel</Name><Value>diesel</Value></Choice><Choice><Name>size</Name><Value>large</Value></Choice></Selections><Choices><Name>uid</Name><Choices><Choice><Name>4F6CBCEE95F7</Name><Value>4F6CBCEE95F7</Value></Choice></Choices></Choices></DrillDownResource></Resources>')
    category = AMEE::Data::Category.get(connection, "/data/transport/car/generic")
    drill = category.drill
    drill.choice_name.should == "fuel"
    drill = drill.choose "diesel"
    drill.choice_name.should == "size"
    drill = drill.choose "large"
    drill.data_item_uid.should == "4F6CBCEE95F7"
  end

end