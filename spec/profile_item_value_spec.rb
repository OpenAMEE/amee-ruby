require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Profile::ItemValue do
  
  before(:each) do
    @value = AMEE::Profile::ItemValue.new
  end
  
  it "should have common AMEE object properties" do
    @value.is_a?(AMEE::Profile::Object).should be_true
  end
  
  it "should have a value" do
    @value.should respond_to(:value)
  end

  it "should have a type" do
    @value.should respond_to(:type)
  end

  it "should have units" do
    @value.should respond_to(:unit)
    @value.should respond_to(:per_unit)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @value = AMEE::Profile::ItemValue.new(:uid => uid)
    @value.uid.should == uid
  end

  it "can be created with hash of data" do
    value = "test"
    type = "STRING"
    unit = "none"
    per_unit = "nothing"
    @value = AMEE::Profile::ItemValue.new(:value => value, :type => type, :unit => unit, :per_unit => per_unit)
    @value.value.should == value
    @value.type.should == type
    @value.unit.should == unit
    @value.per_unit.should == per_unit
  end

  it "should support DOUBLE data type" do
    @value = AMEE::Profile::ItemValue.new(:value => "1.5", :type => "DOUBLE")
    @value.value.should == 1.5
  end

  it "should support TEXT data type" do
    @value = AMEE::Profile::ItemValue.new(:value => "1.5", :type => "TEXT")
    @value.value.should == "1.5"
  end

  it "allows value to be changed after creation" do
    value = "test"
    type = "TEXT"
    @value = AMEE::Profile::ItemValue.new(:value => value, :type => type)
    @value.value.should == value
    value = "hello"
    @value.value = value
    @value.value.should == value
  end

end

describe AMEE::Profile::ItemValue, "with an authenticated connection" do

  it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileItemValueResource><ItemValue Created="2009-03-24 11:15:13.0" Modified="2009-03-24 11:15:20.0" uid="BA4428721987"><Path>kWhPerMonth</Path><Name>kWh Per Month</Name><Value>10</Value><ItemValueDefinition uid="4DF458FD0E4D"><Path>kWhPerMonth</Path><Name>kWh Per Month</Name><FromProfile>true</FromProfile><FromData>false</FromData><ValueDefinition uid="26A5C97D3728"><Name>kWh</Name><ValueType>DOUBLE</ValueType></ValueDefinition></ItemValueDefinition><ProfileItem uid="B099A221106E"/></ItemValue><Path>/home/energy/quantity/B099A221106E/kWhPerMonth</Path><Profile uid="AEC30FB9BCB9"/></ProfileItemValueResource></Resources>'))
    @value = AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")
    @value.uid.should == "BA4428721987"
    @value.name.should == "kWh Per Month"
    @value.path.should == "/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth"
    @value.full_path.should == "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth"
    @value.created.should == DateTime.new(2009,3,24,11,15,13)
    @value.modified.should == DateTime.new(2009,3,24,11,15,20)
    @value.value.should == 10
    @value.unit.should be_nil
    @value.per_unit.should be_nil
    @value.type.should == "DOUBLE"
    @value.from_profile?.should be_true
    @value.from_data?.should be_false
  end

  it "should parse V2 XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption").and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources xmlns="http://schemas.amee.cc/2.0"><ProfileItemValueResource><ItemValue Created="2009-03-24 11:50:32.0" Modified="2009-03-24 11:50:51.0" uid="D19B538D7D84"><Path>energyConsumption</Path><Name>Energy Consumption</Name><Value>10</Value><Unit>kWh</Unit><PerUnit>year</PerUnit><ItemValueDefinition uid="BFD215C4CAB1"><Path>energyConsumption</Path><Name>Energy Consumption</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition><ProfileItem uid="AF8A07038B63"/></ItemValue><Path>/home/energy/quantity/AF8A07038B63/energyConsumption</Path><Profile uid="459AB34FD0FC"/></ProfileItemValueResource></Resources>'))
    @value = AMEE::Profile::ItemValue.get(connection, "/profiles/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption")
    @value.uid.should == "D19B538D7D84"
    @value.name.should == "Energy Consumption"
    @value.path.should == "/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption"
    @value.full_path.should == "/profiles/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption"
    @value.created.should == DateTime.new(2009,3,24,11,50,32)
    @value.modified.should == DateTime.new(2009,3,24,11,50,51)
    @value.value.should == 10
    @value.unit.should == "kWh"
    @value.per_unit.should == "year"
    @value.type.should == "DOUBLE"
    @value.from_profile?.should be_true
    @value.from_data?.should be_false
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_return(flexmock(:body => '{"path":"/home/energy/quantity/B099A221106E/kWhPerMonth","profile":{"uid":"AEC30FB9BCB9"},"itemValue":{"item":{"uid":"B099A221106E"},"modified":"2009-03-24 11:15:20.0","created":"2009-03-24 11:15:13.0","value":"10","uid":"BA4428721987","path":"kWhPerMonth","name":"kWh Per Month","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"26A5C97D3728","name":"kWh"},"uid":"4DF458FD0E4D","path":"kWhPerMonth","name":"kWh Per Month"}}}'))
    @value = AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")
    @value.uid.should == "BA4428721987"
    @value.name.should == "kWh Per Month"
    @value.path.should == "/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth"
    @value.full_path.should == "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth"
    @value.created.should == DateTime.new(2009,3,24,11,15,13)
    @value.modified.should == DateTime.new(2009,3,24,11,15,20)
    @value.value.should == 10
    @value.unit.should be_nil
    @value.per_unit.should be_nil
    @value.type.should == "DOUBLE"
    #@value.from_profile?.should be_false # NOT SET IN JSON
    #@value.from_data?.should be_true # NOT SET IN JSON
  end

  it "should parse V2 JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption").and_return(flexmock(:body => '{"apiVersion":"2.0","itemValue":{"itemValueDefinition":{"perUnit":"year","uid":"BFD215C4CAB1","unit":"kWh","name":"Energy Consumption","path":"energyConsumption","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"D19B538D7D84","unit":"kWh","created":"2009-03-24 11:50:32.0","item":{"uid":"AF8A07038B63","itemValues":[{"itemValueDefinition":{"uid":"E0EFED6FD7E6","name":"Payment frequency","path":"paymentFrequency","valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"}},"perUnit":"","uid":"1640B887FBF1","unit":"","name":"Payment frequency","value":"","path":"paymentFrequency","displayPath":"paymentFrequency","displayName":"Payment frequency"},{"itemValueDefinition":{"uid":"63005554AE8A","name":"Green tariff","path":"greenTariff","valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"}},"perUnit":"","uid":"3D6FBA971997","unit":"","name":"Green tariff","value":"","path":"greenTariff","displayPath":"greenTariff","displayName":"Green tariff"},{"itemValueDefinition":{"uid":"527AADFB3B65","name":"Season","path":"season","valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"}},"perUnit":"","uid":"DCCFE001A1A3","unit":"","name":"Season","value":"","path":"season","displayPath":"season","displayName":"Season"},{"itemValueDefinition":{"uid":"1740E500BDAB","choices":"true=true,false=false","name":"Includes Heating","path":"includesHeating","valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"}},"perUnit":"","uid":"F678696C2BC8","unit":"","name":"Includes Heating","value":"false","path":"includesHeating","displayPath":"includesHeating","displayName":"Includes Heating"},{"itemValueDefinition":{"perUnit":"year","uid":"666C77B224B3","unit":"kg","name":"Mass Per Time","path":"massPerTime","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"6F62EB737262","unit":"kg","name":"Mass Per Time","value":"0","path":"massPerTime","displayPath":"massPerTime","displayName":"Mass Per Time"},{"itemValueDefinition":{"perUnit":"year","uid":"BFD215C4CAB1","unit":"kWh","name":"Energy Consumption","path":"energyConsumption","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"D19B538D7D84","unit":"kWh","name":"Energy Consumption","value":"10","path":"energyConsumption","displayPath":"energyConsumption","displayName":"Energy Consumption"},{"itemValueDefinition":{"perUnit":"year","uid":"A9B493A4A1A6","unit":"kWh","name":"Current Reading","path":"currentReading","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"CBF14AC62D7B","unit":"kWh","name":"Current Reading","value":"0","path":"currentReading","displayPath":"currentReading","displayName":"Current Reading"},{"itemValueDefinition":{"perUnit":"year","uid":"4C689DEF0A41","unit":"kWh","name":"Last Reading","path":"lastReading","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"57F5EF09B890","unit":"kWh","name":"Last Reading","value":"0","path":"lastReading","displayPath":"lastReading","displayName":"Last Reading"},{"itemValueDefinition":{"perUnit":"year","uid":"7BBABF4C2E9E","unit":"L","name":"Volume Per Time","path":"volumePerTime","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"993652F098D6","unit":"L","name":"Volume Per Time","value":"0","path":"volumePerTime","displayPath":"volumePerTime","displayName":"Volume Per Time"},{"itemValueDefinition":{"perUnit":"year","uid":"F0ED40C7EF8F","name":"Number of deliveries","path":"deliveries","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"3BA01E3607B3","unit":"","name":"Number of deliveries","value":"","path":"deliveries","displayPath":"deliveries","displayName":"Number of deliveries"}],"dataCategory":{"uid":"A92693A99BAD","name":"Quantity","path":"quantity"},"startDate":"2009-03-24T11:50:00Z","itemDefinition":{"uid":"212C818D8F16","name":"Energy Quantity","drillDown":"type"},"endDate":"","dataItem":{"uid":"66056991EE23","Label":"gas"},"modified":"2009-03-24T11:50:51Z","amount":{"unit":"kg/year","value":2.055},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10},"created":"2009-03-24T11:50:32Z","name":null,"profile":{"uid":"459AB34FD0FC"}},"name":"Energy Consumption","value":"10","path":"energyConsumption","displayPath":"energyConsumption","displayName":"Energy Consumption","modified":"2009-03-24 11:50:51.0"},"path":"/home/energy/quantity/AF8A07038B63/energyConsumption","actions":{"allowCreate":true,"allowView":true,"allowList":true,"allowModify":true,"allowDelete":true},"profile":{"uid":"459AB34FD0FC"}}'))
    @value = AMEE::Profile::ItemValue.get(connection, "/profiles/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption")
    @value.uid.should == "D19B538D7D84"
    @value.name.should == "Energy Consumption"
    @value.path.should == "/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption"
    @value.full_path.should == "/profiles/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption"
    @value.created.should == DateTime.new(2009,3,24,11,50,32)
    @value.modified.should == DateTime.new(2009,3,24,11,50,51)
    @value.value.should == 10
    @value.unit.should == "kWh"
    @value.per_unit.should == "year"
    @value.type.should == "DOUBLE"
  end

  it "should fail gracefully with incorrect XML data" do
    connection = flexmock "connection"
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_return(flexmock(:body => xml))
    lambda{AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    json = '{}'
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_return(flexmock(:body => json))
    lambda{AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")}.should raise_error(AMEE::BadData)
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_raise("unidentified error")
    lambda{AMEE::Profile::ItemValue.get(connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")}.should raise_error(AMEE::BadData)
  end

end

describe AMEE::Profile::ItemValue, "after loading v1" do

  before(:each) do
    @connection = flexmock "connection"
    @connection.should_receive(:get).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth").and_return(flexmock(:body => '{"path":"/home/energy/quantity/B099A221106E/kWhPerMonth","profile":{"uid":"AEC30FB9BCB9"},"itemValue":{"item":{"uid":"B099A221106E"},"modified":"2009-03-24 11:15:20.0","created":"2009-03-24 11:15:13.0","value":"10","uid":"BA4428721987","path":"kWhPerMonth","name":"kWh Per Month","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"26A5C97D3728","name":"kWh"},"uid":"4DF458FD0E4D","path":"kWhPerMonth","name":"kWh Per Month"}}}'))
    @val = AMEE::Profile::ItemValue.get(@connection, "/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth")
  end

  it "can have value changed and saved back to server" do
    @connection.should_receive(:put).with("/profiles/AEC30FB9BCB9/home/energy/quantity/B099A221106E/kWhPerMonth", {:value => 42}).and_return(flexmock(:body => ''))
    lambda {
      @val.value = 42
      @val.save!
    }.should_not raise_error
  end

end

describe AMEE::Profile::ItemValue, "after loading v2" do

  before(:each) do
    @connection = flexmock "connection"
    @connection.should_receive(:get).with("/profiles/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption").and_return(flexmock(:body => '{"apiVersion":"2.0","itemValue":{"itemValueDefinition":{"perUnit":"year","uid":"BFD215C4CAB1","unit":"kWh","name":"Energy Consumption","path":"energyConsumption","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"D19B538D7D84","unit":"kWh","created":"2009-03-24 11:50:32.0","item":{"uid":"AF8A07038B63","itemValues":[{"itemValueDefinition":{"uid":"E0EFED6FD7E6","name":"Payment frequency","path":"paymentFrequency","valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"}},"perUnit":"","uid":"1640B887FBF1","unit":"","name":"Payment frequency","value":"","path":"paymentFrequency","displayPath":"paymentFrequency","displayName":"Payment frequency"},{"itemValueDefinition":{"uid":"63005554AE8A","name":"Green tariff","path":"greenTariff","valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"}},"perUnit":"","uid":"3D6FBA971997","unit":"","name":"Green tariff","value":"","path":"greenTariff","displayPath":"greenTariff","displayName":"Green tariff"},{"itemValueDefinition":{"uid":"527AADFB3B65","name":"Season","path":"season","valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"}},"perUnit":"","uid":"DCCFE001A1A3","unit":"","name":"Season","value":"","path":"season","displayPath":"season","displayName":"Season"},{"itemValueDefinition":{"uid":"1740E500BDAB","choices":"true=true,false=false","name":"Includes Heating","path":"includesHeating","valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 09:30:44.0"}},"perUnit":"","uid":"F678696C2BC8","unit":"","name":"Includes Heating","value":"false","path":"includesHeating","displayPath":"includesHeating","displayName":"Includes Heating"},{"itemValueDefinition":{"perUnit":"year","uid":"666C77B224B3","unit":"kg","name":"Mass Per Time","path":"massPerTime","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"6F62EB737262","unit":"kg","name":"Mass Per Time","value":"0","path":"massPerTime","displayPath":"massPerTime","displayName":"Mass Per Time"},{"itemValueDefinition":{"perUnit":"year","uid":"BFD215C4CAB1","unit":"kWh","name":"Energy Consumption","path":"energyConsumption","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"D19B538D7D84","unit":"kWh","name":"Energy Consumption","value":"10","path":"energyConsumption","displayPath":"energyConsumption","displayName":"Energy Consumption"},{"itemValueDefinition":{"perUnit":"year","uid":"A9B493A4A1A6","unit":"kWh","name":"Current Reading","path":"currentReading","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"CBF14AC62D7B","unit":"kWh","name":"Current Reading","value":"0","path":"currentReading","displayPath":"currentReading","displayName":"Current Reading"},{"itemValueDefinition":{"perUnit":"year","uid":"4C689DEF0A41","unit":"kWh","name":"Last Reading","path":"lastReading","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"57F5EF09B890","unit":"kWh","name":"Last Reading","value":"0","path":"lastReading","displayPath":"lastReading","displayName":"Last Reading"},{"itemValueDefinition":{"perUnit":"year","uid":"7BBABF4C2E9E","unit":"L","name":"Volume Per Time","path":"volumePerTime","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"993652F098D6","unit":"L","name":"Volume Per Time","value":"0","path":"volumePerTime","displayPath":"volumePerTime","displayName":"Volume Per Time"},{"itemValueDefinition":{"perUnit":"year","uid":"F0ED40C7EF8F","name":"Number of deliveries","path":"deliveries","valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 09:30:44.0","description":"","name":"amount","valueType":"DOUBLE","modified":"2007-07-27 09:30:44.0"}},"perUnit":"year","uid":"3BA01E3607B3","unit":"","name":"Number of deliveries","value":"","path":"deliveries","displayPath":"deliveries","displayName":"Number of deliveries"}],"dataCategory":{"uid":"A92693A99BAD","name":"Quantity","path":"quantity"},"startDate":"2009-03-24T11:50:00Z","itemDefinition":{"uid":"212C818D8F16","name":"Energy Quantity","drillDown":"type"},"endDate":"","dataItem":{"uid":"66056991EE23","Label":"gas"},"modified":"2009-03-24T11:50:51Z","amount":{"unit":"kg/year","value":2.055},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10},"created":"2009-03-24T11:50:32Z","name":null,"profile":{"uid":"459AB34FD0FC"}},"name":"Energy Consumption","value":"10","path":"energyConsumption","displayPath":"energyConsumption","displayName":"Energy Consumption","modified":"2009-03-24 11:50:51.0"},"path":"/home/energy/quantity/AF8A07038B63/energyConsumption","actions":{"allowCreate":true,"allowView":true,"allowList":true,"allowModify":true,"allowDelete":true},"profile":{"uid":"459AB34FD0FC"}}'))
    @val = AMEE::Profile::ItemValue.get(@connection, "/profiles/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption")
  end

  it "can have value changed and saved back to server" do
    @connection.should_receive(:put).with("/profiles/459AB34FD0FC/home/energy/quantity/AF8A07038B63/energyConsumption", {:value => 42, :unit => "kWh", :perUnit => "year"}).and_return(flexmock(:body => ''))
    lambda {
      @val.value = 42
      @val.unit = "kWh"
      @val.per_unit = "year"
      @val.save!
    }.should_not raise_error
  end

end
