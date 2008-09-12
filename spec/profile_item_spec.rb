require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Profile::Item do
  
  before(:each) do
    @item = AMEE::Profile::Item.new
  end
  
  it "should have common AMEE object properties" do
    @item.is_a?(AMEE::Profile::Object).should be_true
  end
  
  it "should have values" do
    @item.should respond_to(:values)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @item = AMEE::Profile::Item.new(:uid => uid)
    @item.uid.should == uid
  end

  it "can be created with hash of data" do
    values = ["one", "two"]
    @item = AMEE::Profile::Item.new(:values => values)
    @item.values.should == values
  end
 
  it "should be able to create new profile items (XML)" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/energy/quantity", {:profileDate=>Date.today.strftime("%Y%m")}).and_return('{"totalAmountPerMonth":105.472,"dataCategory":{"uid":"A92693A99BAD","path":"quantity","name":"Quantity"},"profileDate":"200809","path":"/home/energy/quantity","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{"to":2,"lastPage":1,"start":0,"nextPage":-1,"items":2,"itemsPerPage":10,"from":1,"previousPage":-1,"requestedPage":1,"currentPage":1,"itemsFound":2},"dataCategories":[],"profileItems":{"rows":[{"created":"2008-09-03 11:37:35.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"FB07247AD937","modified":"2008-09-03 11:38:12.0","dataItemUid":"66056991EE23","validFrom":"20080902","amountPerMonth":"2.472","label":"ProfileItem","litresPerMonth":"0","path":"FB07247AD937","kWhPerMonth":"12","name":"gas"},{"created":"2008-09-03 11:40:44.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"D9CBCDED44C5","modified":"2008-09-03 11:41:54.0","dataItemUid":"66056991EE23","validFrom":"20080901","amountPerMonth":"103.000","label":"ProfileItem","litresPerMonth":"0","path":"D9CBCDED44C5","kWhPerMonth":"500","name":"gas2"}],"label":"ProfileItems"}}}')
    connection.should_receive(:post).with("/profiles/E54C5525AA3E/home/energy/quantity", :dataItemUid => '66056991EE23').and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><ProfileItem created="Fri May 18 16:16:42 BST 2007" modified="Fri May 18 16:16:43 BST 2007" uid="782AC515F94B"><amountPerMonth>397.900</amountPerMonth><validFrom>20070501</validFrom><end>false</end><DataItem uid="66056991EE23"><name>29E52582826A</name><path>29E52582826A</path><label>gas</label></DataItem><name>782AC515F94B</name><ItemDefinition uid="B354BA63010D"/></ProfileItem></ProfileCategoryResource></Resources>')
    category = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home/energy/quantity")
    item = AMEE::Profile::Item.create(category, '66056991EE23')
    item.should_not be_nil
  end

end

describe AMEE::Profile::Category, "with an authenticated XML connection" do

  it "should load Profile Item" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753", {:profileDate=>Date.today.strftime("%Y%m")}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileItemResource><ProfileItem created="2008-09-12 17:20:32.0" modified="2008-09-12 17:20:32.0" uid="6E9B1517D753"><Name>6E9B1517D753</Name><ItemValues><ItemValue uid="0A671BF3D593"><Path>kgPerMonth</Path><Name>kg Per Month</Name><Value>10</Value><ItemValueDefinition uid="51D072825D41"><Path>kgPerMonth</Path><Name>kg Per Month</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="36A771FC1D1A"><Name>kg</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="0E4CF565A5AB"><Path>kWhPerMonth</Path><Name>kWh Per Month</Name><Value>0</Value><ItemValueDefinition uid="4DF458FD0E4D"><Path>kWhPerMonth</Path><Name>kWh Per Month</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="26A5C97D3728"><Name>kWh</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="D58700708731"><Path>litresPerMonth</Path><Name>Litres Per Month</Name><Value>0</Value><ItemValueDefinition uid="C9B7E19269A5"><Path>litresPerMonth</Path><Name>Litres Per Month</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="06B8CFC5A521"><Name>litre</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="BD1267F2D001"><Path>kWhReadingCurrent</Path><Name>kWh reading current</Name><Value>0</Value><ItemValueDefinition uid="8A468E75C8E8"><Path>kWhReadingCurrent</Path><Name>kWh reading current</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="B199A908A259"><Path>kWhReadingLast</Path><Name>kWh reading last</Name><Value>0</Value><ItemValueDefinition uid="2328DC7F23AE"><Path>kWhReadingLast</Path><Name>kWh reading last</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue></ItemValues><Environment uid="5F5887BCF726"/><ItemDefinition uid="212C818D8F16"/><DataCategory uid="A92693A99BAD"><Name>Quantity</Name><Path>quantity</Path></DataCategory><AmountPerMonth>25.200</AmountPerMonth><ValidFrom>20080901</ValidFrom><End>false</End><DataItem uid="A70149AF0F26"/><Profile uid="92C8DB30F46B"/></ProfileItem><Path>/home/energy/quantity/6E9B1517D753</Path><Profile uid="92C8DB30F46B"/></ProfileItemResource></Resources>')
    @item = AMEE::Profile::Item.get(connection, "/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753")
    @item.profile_uid.should == "92C8DB30F46B"
    @item.uid.should == "6E9B1517D753"
    @item.name.should == "6E9B1517D753"
    @item.path.should == "/home/energy/quantity/6E9B1517D753"
    @item.total_amount_per_month.should be_close(25.2, 1e-9)
    @item.valid_from.should == DateTime.new(2008, 9, 1)
    @item.end.should be_false
    @item.full_path.should == "/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753"
  end

  it "should parse values" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753", {:profileDate=>Date.today.strftime("%Y%m")}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileItemResource><ProfileItem created="2008-09-12 17:20:32.0" modified="2008-09-12 17:20:32.0" uid="6E9B1517D753"><Name>6E9B1517D753</Name><ItemValues><ItemValue uid="0A671BF3D593"><Path>kgPerMonth</Path><Name>kg Per Month</Name><Value>10</Value><ItemValueDefinition uid="51D072825D41"><Path>kgPerMonth</Path><Name>kg Per Month</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="36A771FC1D1A"><Name>kg</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="0E4CF565A5AB"><Path>kWhPerMonth</Path><Name>kWh Per Month</Name><Value>0</Value><ItemValueDefinition uid="4DF458FD0E4D"><Path>kWhPerMonth</Path><Name>kWh Per Month</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="26A5C97D3728"><Name>kWh</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="D58700708731"><Path>litresPerMonth</Path><Name>Litres Per Month</Name><Value>0</Value><ItemValueDefinition uid="C9B7E19269A5"><Path>litresPerMonth</Path><Name>Litres Per Month</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="06B8CFC5A521"><Name>litre</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="BD1267F2D001"><Path>kWhReadingCurrent</Path><Name>kWh reading current</Name><Value>0</Value><ItemValueDefinition uid="8A468E75C8E8"><Path>kWhReadingCurrent</Path><Name>kWh reading current</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue><ItemValue uid="B199A908A259"><Path>kWhReadingLast</Path><Name>kWh reading last</Name><Value>0</Value><ItemValueDefinition uid="2328DC7F23AE"><Path>kWhReadingLast</Path><Name>kWh reading last</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType></ValueDefinition></ItemValueDefinition></ItemValue></ItemValues><Environment uid="5F5887BCF726"/><ItemDefinition uid="212C818D8F16"/><DataCategory uid="A92693A99BAD"><Name>Quantity</Name><Path>quantity</Path></DataCategory><AmountPerMonth>25.200</AmountPerMonth><ValidFrom>20080901</ValidFrom><End>false</End><DataItem uid="A70149AF0F26"/><Profile uid="92C8DB30F46B"/></ProfileItem><Path>/home/energy/quantity/6E9B1517D753</Path><Profile uid="92C8DB30F46B"/></ProfileItemResource></Resources>')
    @item = AMEE::Profile::Item.get(connection, "/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753")
    @item.values.size.should be(5)
    @item.values[0][:uid].should == "0A671BF3D593"
    @item.values[0][:name].should == "kg Per Month"
    @item.values[0][:path].should == "kgPerMonth"
    @item.values[0][:value].should == "10"
    @item.values[1][:uid].should == "0E4CF565A5AB"
    @item.values[1][:name].should == "kWh Per Month"
    @item.values[1][:path].should == "kWhPerMonth"
    @item.values[1][:value].should == "0"
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753", {:profileDate=>Date.today.strftime("%Y%m")}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>')
    lambda{AMEE::Profile::Item.get(connection, "/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753")}.should raise_error(AMEE::BadData, "Couldn't load ProfileItem from XML data. Check that your URL is correct.")
  end

end

describe AMEE::Profile::Category, "with an authenticated JSON connection" do

  it "should load Profile Item" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753", {:profileDate=>Date.today.strftime("%Y%m")}).and_return('{"path":"/home/energy/quantity/6E9B1517D753","profile":{"uid":"92C8DB30F46B"},"profileItem":{"created":"2008-09-12 17:20:32.0","itemValues":[{"value":"10","uid":"0A671BF3D593","path":"kgPerMonth","name":"kg Per Month","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"36A771FC1D1A","name":"kg"},"uid":"51D072825D41","path":"kgPerMonth","name":"kg Per Month"}},{"value":"0","uid":"0E4CF565A5AB","path":"kWhPerMonth","name":"kWh Per Month","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"26A5C97D3728","name":"kWh"},"uid":"4DF458FD0E4D","path":"kWhPerMonth","name":"kWh Per Month"}},{"value":"0","uid":"D58700708731","path":"litresPerMonth","name":"Litres Per Month","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"06B8CFC5A521","name":"litre"},"uid":"C9B7E19269A5","path":"litresPerMonth","name":"Litres Per Month"}},{"value":"0","uid":"BD1267F2D001","path":"kWhReadingCurrent","name":"kWh reading current","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"45433E48B39F","name":"amount"},"uid":"8A468E75C8E8","path":"kWhReadingCurrent","name":"kWh reading current"}},{"value":"0","uid":"B199A908A259","path":"kWhReadingLast","name":"kWh reading last","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"45433E48B39F","name":"amount"},"uid":"2328DC7F23AE","path":"kWhReadingLast","name":"kWh reading last"}}],"dataCategory":{"uid":"A92693A99BAD","path":"quantity","name":"Quantity"},"end":"false","uid":"6E9B1517D753","environment":{"uid":"5F5887BCF726"},"profile":{"uid":"92C8DB30F46B"},"modified":"2008-09-12 17:20:32.0","validFrom":"20080901","amountPerMonth":25.2,"itemDefinition":{"uid":"212C818D8F16"},"dataItem":{"uid":"A70149AF0F26"},"name":"6E9B1517D753"}}')
    @item = AMEE::Profile::Item.get(connection, "/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753")
    @item.profile_uid.should == "92C8DB30F46B"
    @item.uid.should == "6E9B1517D753"
    @item.name.should == "6E9B1517D753"
    @item.path.should == "/home/energy/quantity/6E9B1517D753"
    @item.total_amount_per_month.should be_close(25.2, 1e-9)
    @item.valid_from.should == DateTime.new(2008, 9, 1)
    @item.end.should be_false
    @item.full_path.should == "/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753"
  end

  it "should parse values" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753", {:profileDate=>Date.today.strftime("%Y%m")}).and_return('{"path":"/home/energy/quantity/6E9B1517D753","profile":{"uid":"92C8DB30F46B"},"profileItem":{"created":"2008-09-12 17:20:32.0","itemValues":[{"value":"10","uid":"0A671BF3D593","path":"kgPerMonth","name":"kg Per Month","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"36A771FC1D1A","name":"kg"},"uid":"51D072825D41","path":"kgPerMonth","name":"kg Per Month"}},{"value":"0","uid":"0E4CF565A5AB","path":"kWhPerMonth","name":"kWh Per Month","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"26A5C97D3728","name":"kWh"},"uid":"4DF458FD0E4D","path":"kWhPerMonth","name":"kWh Per Month"}},{"value":"0","uid":"D58700708731","path":"litresPerMonth","name":"Litres Per Month","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"06B8CFC5A521","name":"litre"},"uid":"C9B7E19269A5","path":"litresPerMonth","name":"Litres Per Month"}},{"value":"0","uid":"BD1267F2D001","path":"kWhReadingCurrent","name":"kWh reading current","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"45433E48B39F","name":"amount"},"uid":"8A468E75C8E8","path":"kWhReadingCurrent","name":"kWh reading current"}},{"value":"0","uid":"B199A908A259","path":"kWhReadingLast","name":"kWh reading last","itemValueDefinition":{"valueDefinition":{"valueType":"DECIMAL","uid":"45433E48B39F","name":"amount"},"uid":"2328DC7F23AE","path":"kWhReadingLast","name":"kWh reading last"}}],"dataCategory":{"uid":"A92693A99BAD","path":"quantity","name":"Quantity"},"end":"false","uid":"6E9B1517D753","environment":{"uid":"5F5887BCF726"},"profile":{"uid":"92C8DB30F46B"},"modified":"2008-09-12 17:20:32.0","validFrom":"20080901","amountPerMonth":25.2,"itemDefinition":{"uid":"212C818D8F16"},"dataItem":{"uid":"A70149AF0F26"},"name":"6E9B1517D753"}}')
    @item = AMEE::Profile::Item.get(connection, "/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753")
    @item.values.size.should be(5)
    @item.values[0][:uid].should == "0A671BF3D593"
    @item.values[0][:name].should == "kg Per Month"
    @item.values[0][:path].should == "kgPerMonth"
    @item.values[0][:value].should == "10"
    @item.values[1][:uid].should == "0E4CF565A5AB"
    @item.values[1][:name].should == "kWh Per Month"
    @item.values[1][:path].should == "kWhPerMonth"
    @item.values[1][:value].should == "0"
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753", {:profileDate=>Date.today.strftime("%Y%m")}).and_return('{}')
    lambda{AMEE::Profile::Item.get(connection, "/profiles/92C8DB30F46B/home/energy/quantity/6E9B1517D753")}.should raise_error(AMEE::BadData, "Couldn't load ProfileItem from JSON data. Check that your URL is correct.")
  end

end
