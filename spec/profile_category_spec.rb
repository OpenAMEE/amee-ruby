# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'

describe AMEE::Profile::Category do

  before(:each) do
    @cat = AMEE::Profile::Category.new
  end

  it "should have common AMEE object properties" do
    @cat.is_a?(AMEE::Profile::Object).should be_true
  end

  it "should have a total co2 amount and unit" do
    @cat.should respond_to(:total_amount)
    @cat.should respond_to(:total_amount_unit)
  end

  it "should have children" do
    @cat.should respond_to(:children)
  end

  it "should have items" do
    @cat.should respond_to(:items)
  end

  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    @cat = AMEE::Profile::Category.new(:uid => uid)
    @cat.uid.should == uid
  end

  it "can be created with hash of data" do
    children = ["one", "two"]
    items = ["three", "four"]
    @cat = AMEE::Profile::Category.new(:children => children, :items => items)
    @cat.children.should == children
    @cat.items.should == items
  end

end

describe AMEE::Profile::Category, "accessing AMEE V0" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/D4B9755F671D/home", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><DataCategory created="2007-04-16 17:50:43.0" modified="2007-04-16 17:50:43.0" uid="248D8617A389"><name>Home</name><path>home</path></DataCategory><Profile uid="D4B9755F671D"/><Children><DataCategories><DataCategory uid="3A72CC3F2AC9"><name>Television</name><path>television</path></DataCategory><DataCategory uid="51FF7A9A1D84"><name>Seasonal Billing</name><path>seasonal_billing</path></DataCategory><DataCategory uid="83B7E4488D34"><name>Heating</name><path>heating</path></DataCategory><DataCategory uid="8B5A3EF67252"><name>Fuel</name><path>fuel</path></DataCategory><DataCategory uid="97888F42B5D6"><name>Lighting</name><path>lighting</path></DataCategory><DataCategory uid="0D260A2B9E56"><name>Fuel Price</name><path>fuel_price</path></DataCategory><DataCategory uid="2A018E464460"><name>Appliances</name><path>appliances</path></DataCategory><DataCategory uid="A937C019FA6F"><name>Cooking</name><path>cooking</path></DataCategory></DataCategories></Children><ProfileDate>200902</ProfileDate></ProfileCategoryResource></Resources>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/D4B9755F671D/home")
    @cat.profile_uid.should == "D4B9755F671D"
    @cat.profile_date.should == DateTime.new(2009, 2)
    @cat.name.should == "Home"
    @cat.path.should == "/home"
    @cat.full_path.should == "/profiles/D4B9755F671D/home"
    @cat.children.size.should be(8)
    @cat.children[0][:uid].should == "3A72CC3F2AC9"
    @cat.children[0][:name].should == "Television"
    @cat.children[0][:path].should == "television"
    @cat.pager.should be_nil
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/D4B9755F671D/transport/transport", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><DataCategory created="2007-04-16 17:50:43.0" modified="2007-04-16 17:50:43.0" uid="CD13B9174A6A"><name>Transport</name><path>transport</path></DataCategory><Profile uid="D4B9755F671D"/><Children><DataCategories/><ProfileItems><ProfileItem created="2009-02-19 16:50:26.0" modified="2009-02-19 16:50:27.0" uid="05BB9D4AF86D"><validFrom>20090201</validFrom><end>false</end><transportAdhereToSpeedLimit>false</transportAdhereToSpeedLimit><transportTyresUnderInflated>false</transportTyresUnderInflated><transportAirConAverage>false</transportAirConAverage><transportKmPerLitre>1</transportKmPerLitre><transportEcoDriving>false</transportEcoDriving><transportDistance>0</transportDistance><amountPerMonth>21.42</amountPerMonth><transportAirConFull>false</transportAirConFull><dataItemUid>25A341E24BCE</dataItemUid><transportNumberOfJourneys>0.0833333333333333</transportNumberOfJourneys><name/><dataItemLabel>Flights, Short haul, Return</dataItemLabel></ProfileItem><ProfileItem created="2009-02-19 16:48:47.0" modified="2009-02-19 16:48:47.0" uid="D6FE02356302"><validFrom>20090201</validFrom><end>false</end><transportAdhereToSpeedLimit>false</transportAdhereToSpeedLimit><transportTyresUnderInflated>false</transportTyresUnderInflated><transportAirConAverage>false</transportAirConAverage><transportKmPerLitre>14.16</transportKmPerLitre><transportEcoDriving>false</transportEcoDriving><transportDistance>1340.83333333333</transportDistance><amountPerMonth>286.39</amountPerMonth><transportAirConFull>false</transportAirConFull><dataItemUid>3CAFBEA600F4</dataItemUid><transportNumberOfJourneys>0</transportNumberOfJourneys><name/><dataItemLabel>Car1, Fuel manufacturer consumption, Diesel</dataItemLabel></ProfileItem></ProfileItems></Children><ProfileDate>200902</ProfileDate><TotalAmountPerMonth>307.81</TotalAmountPerMonth></ProfileCategoryResource></Resources>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/D4B9755F671D/transport/transport")
    @cat.total_amount.should be_within(1.0e-09).of(307.81)
    @cat.total_amount_unit.should == "kg/month"
    @cat.items.size.should be(2)
    @cat.items[0][:uid].should == "05BB9D4AF86D"
    @cat.items[0][:name].should be_nil
    @cat.items[0][:path].should == "05BB9D4AF86D"
    @cat.items[0][:dataItemLabel].should == "Flights, Short haul, Return"
    @cat.items[0][:dataItemUid].should == "25A341E24BCE"
    @cat.items[0][:validFrom].should == DateTime.new(2009, 2, 1)
    @cat.items[0][:end].should == false
    @cat.items[0][:amountPerMonth].should be_within(1.0e-09).of(21.42)
    @cat.items[0][:values].size.should be(8)
    @cat.items[0][:values][:transportNumberOfJourneys].should == "0.0833333333333333"
    @cat.items[0][:values][:transportEcoDriving].should == "false"
    @cat.pager.should be_nil
  end

end

describe AMEE::Profile::Category, "with an authenticated XML connection" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><Children><ProfileCategories><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><DataCategory uid="30BA55A0C472"><Name>Energy</Name><Path>energy</Path></DataCategory><DataCategory uid="A46ECFA19333"><Name>Heating</Name><Path>heating</Path></DataCategory><DataCategory uid="150266DD4434"><Name>Lighting</Name><Path>lighting</Path></DataCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home")
    @cat.profile_uid.should == "E54C5525AA3E"
    @cat.profile_date.should == DateTime.new(2008, 9)
    @cat.name.should == "Home"
    @cat.path.should == "/home"
    @cat.full_path.should == "/profiles/E54C5525AA3E/home"
    @cat.children.size.should be(4)
    @cat.children[0][:uid].should == "427DFCC65E52"
    @cat.children[0][:name].should == "Appliances"
    @cat.children[0][:path].should == "appliances"
    @cat.pager.should be_nil
  end

  it "should provide access to child objects" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><Children><ProfileCategories><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><DataCategory uid="30BA55A0C472"><Name>Energy</Name><Path>energy</Path></DataCategory><DataCategory uid="A46ECFA19333"><Name>Heating</Name><Path>heating</Path></DataCategory><DataCategory uid="150266DD4434"><Name>Lighting</Name><Path>lighting</Path></DataCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>'))
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/appliances", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home/appliances</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><Children><ProfileCategories><DataCategory uid="3FE23FDC8CEA"><Name>Computers</Name><Path>computers</Path></DataCategory><DataCategory uid="54C8A44254AA"><Name>Cooking</Name><Path>cooking</Path></DataCategory><DataCategory uid="75AD9B83B7BF"><Name>Entertainment</Name><Path>entertainment</Path></DataCategory><DataCategory uid="4BD595E1873A"><Name>Kitchen</Name><Path>kitchen</Path></DataCategory><DataCategory uid="700D0771870A"><Name>Televisions</Name><Path>televisions</Path></DataCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home")
    @child = @cat.child('appliances')
    @child.path.should == "/home/appliances"
    @child.full_path.should == "/profiles/E54C5525AA3E/home/appliances"
    @child.children.size.should be(5)
    @child.pager.should be_nil
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/energy/quantity", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home/energy/quantity</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="A92693A99BAD"><Name>Quantity</Name><Path>quantity</Path></DataCategory><Children><ProfileCategories/><ProfileItems><ProfileItem created="2008-09-03 11:37:35.0" modified="2008-09-03 11:38:12.0" uid="FB07247AD937"><validFrom>20080902</validFrom><end>false</end><kWhPerMonth>12</kWhPerMonth><amountPerMonth>2.472</amountPerMonth><dataItemUid>66056991EE23</dataItemUid><kgPerMonth>0</kgPerMonth><path>FB07247AD937</path><litresPerMonth>0</litresPerMonth><name>gas</name><dataItemLabel>gas</dataItemLabel></ProfileItem><ProfileItem created="2008-09-03 11:40:44.0" modified="2008-09-03 11:41:54.0" uid="D9CBCDED44C5"><validFrom>20080901</validFrom><end>false</end><kWhPerMonth>500</kWhPerMonth><amountPerMonth>103.000</amountPerMonth><dataItemUid>66056991EE23</dataItemUid><kgPerMonth>0</kgPerMonth><path>D9CBCDED44C5</path><litresPerMonth>0</litresPerMonth><name>gas2</name><dataItemLabel>gas</dataItemLabel></ProfileItem></ProfileItems><Pager><Start>0</Start><From>1</From><To>2</To><Items>2</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>2</ItemsFound></Pager></Children><TotalAmountPerMonth>105.472</TotalAmountPerMonth></ProfileCategoryResource></Resources>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home/energy/quantity")
    @cat.total_amount.should be_within(1.0e-09).of(105.472)
    @cat.total_amount_unit.should == "kg/month"
    @cat.items.size.should be(2)
    @cat.items[0][:uid].should == "FB07247AD937"
    @cat.items[0][:name].should == "gas"
    @cat.items[0][:path].should == "FB07247AD937"
    @cat.items[0][:dataItemLabel].should == "gas"
    @cat.items[0][:dataItemUid].should == "66056991EE23"
    @cat.items[0][:validFrom].should == DateTime.new(2008, 9, 2)
    @cat.items[0][:end].should == false
    @cat.items[0][:amountPerMonth].should be_within(1.0e-09).of(2.472)
    @cat.items[0][:values].size.should be(3)
    @cat.items[0][:values][:kWhPerMonth].should == "12"
    @cat.items[0][:values][:kgPerMonth].should == "0"
    @cat.items[0][:values][:litresPerMonth].should == "0"
    @cat.pager.should_not be_nil
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:get).with("/profiles/E54C5525AA3E", {}).and_return(flexmock(:body => xml))
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData)
  end

  it "parses recursive GET requests" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/BE22C1732952/transport/car", {:recurse=>true}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/transport/car</Path><ProfileDate>200901</ProfileDate><Profile uid="BE22C1732952"/><DataCategory uid="1D95119FB149"><Name>Car</Name><Path>car</Path></DataCategory><Children><ProfileCategories><ProfileCategory><Path>/transport/car/bands</Path><DataCategory uid="883ADD27228F"><Name>Bands</Name><Path>bands</Path></DataCategory></ProfileCategory><ProfileCategory><Path>/transport/car/generic</Path><DataCategory uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path></DataCategory><Children><ProfileCategories><ProfileCategory><Path>/transport/car/generic/electric</Path><DataCategory uid="417DD367E9AA"><Name>Electric</Name><Path>electric</Path></DataCategory></ProfileCategory></ProfileCategories><ProfileItems><ProfileItem created="2009-01-05 13:58:52.0" modified="2009-01-05 13:59:05.0" uid="8450D6D97D2D"><distanceKmPerMonth>1</distanceKmPerMonth><validFrom>20090101</validFrom><end>false</end><airconTypical>true</airconTypical><ecoDriving>false</ecoDriving><airconFull>false</airconFull><kmPerLitreOwn>0</kmPerLitreOwn><country/><tyresUnderinflated>false</tyresUnderinflated><amountPerMonth>0.265</amountPerMonth><occupants>-1</occupants><kmPerLitre>0</kmPerLitre><dataItemUid>4F6CBCEE95F7</dataItemUid><regularlyServiced>true</regularlyServiced><path>8450D6D97D2D</path><name/><dataItemLabel>diesel, large</dataItemLabel></ProfileItem></ProfileItems></Children><TotalAmountPerMonth>0.265</TotalAmountPerMonth></ProfileCategory><ProfileCategory><Path>/transport/car/specific</Path><DataCategory uid="95E76249584D"><Name>Specific</Name><Path>specific</Path></DataCategory></ProfileCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>'))
    cat = AMEE::Profile::Category.get(connection, "/profiles/BE22C1732952/transport/car", :recurse => true)
    cat.items.size.should == 0
    cat.children.size.should == 3
    cat.children[1][:name].should == "Generic"
    cat.children[1][:path].should == "generic"
    cat.children[1][:uid].should == "87E55DA88017"
    cat.children[1][:totalAmountPerMonth].should == 0.265
    cat.children[1][:children].size.should == 1
    cat.children[1][:children][0][:name].should == "Electric"
    cat.children[1][:children][0][:path].should == "electric"
    cat.children[1][:children][0][:uid].should == "417DD367E9AA"
    cat.children[1][:items].size.should == 1
    cat.children[1][:items][0][:amountPerMonth].should == 0.265
    cat.children[1][:items][0][:dataItemLabel].should == "diesel, large"
    cat.children[1][:items][0][:dataItemUid].should == "4F6CBCEE95F7"
    cat.children[1][:items][0][:values][:airconTypical].should == "true"
    cat.children[1][:items][0][:uid].should == "8450D6D97D2D"
    cat.pager.should be_nil
  end

end

describe AMEE::Profile::Category, "with an authenticated version 2 XML connection" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    connection.should_receive(:get).with("/profiles/26532D8EFA9D/home", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?> <Resources xmlns="http://schemas.amee.cc/2.0"><ProfileCategoryResource><Path>/home</Path><Profile uid="26532D8EFA9D"/><Environment created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="5F5887BCF726"><Name>AMEE</Name><Path/><Description/><Owner/><ItemsPerPage>10</ItemsPerPage><ItemsPerFeed>10</ItemsPerFeed></Environment><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><ProfileCategories><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><DataCategory uid="30BA55A0C472"><Name>Energy</Name><Path>energy</Path></DataCategory><DataCategory uid="A46ECFA19333"><Name>Heating</Name><Path>heating</Path></DataCategory><DataCategory uid="150266DD4434"><Name>Lighting</Name><Path>lighting</Path></DataCategory><DataCategory uid="6553150F96CE"><Name>Waste</Name><Path>waste</Path></DataCategory><DataCategory uid="07362DCC9E7B"><Name>Water</Name><Path>water</Path></DataCategory></ProfileCategories></ProfileCategoryResource></Resources>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/26532D8EFA9D/home")
    @cat.profile_uid.should == "26532D8EFA9D"
    @cat.name.should == "Home"
    @cat.path.should == "/home"
    @cat.full_path.should == "/profiles/26532D8EFA9D/home"
    @cat.children.size.should be(6)
    @cat.children[0][:uid].should == "427DFCC65E52"
    @cat.children[0][:name].should == "Appliances"
    @cat.children[0][:path].should == "appliances"
    @cat.pager.should be_nil
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    connection.should_receive(:get).with("/profiles/26532D8EFA9D/home/energy/quantity", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?> <Resources xmlns="http://schemas.amee.cc/2.0"><ProfileCategoryResource><Path>/home/energy/quantity</Path><Profile uid="9BFB0C1CD78A"/><Environment created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="5F5887BCF726"><Name>AMEE</Name><Path/><Description/><Owner/><ItemsPerPage>10</ItemsPerPage><ItemsPerFeed>10</ItemsPerFeed></Environment><DataCategory uid="A92693A99BAD"><Name>Quantity</Name><Path>quantity</Path></DataCategory><ProfileCategories/><ProfileItems><ProfileItem created="2009-02-11T13:50+0000" modified="2009-02-11T13:50+0000" uid="30C00AD33033"><Name>gas</Name><ItemValues><ItemValue uid="570843C78E93"><Path>paymentFrequency</Path><Name>Payment frequency</Name><Value/><Unit/><PerUnit/><ItemValueDefinition uid="E0EFED6FD7E6"><Path>paymentFrequency</Path><Name>Payment frequency</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="C71B646F8502"><Path>greenTariff</Path><Name>Green tariff</Name><Value/><Unit/><PerUnit/><ItemValueDefinition uid="63005554AE8A"><Path>greenTariff</Path><Name>Green tariff</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="8231B25E416F"><Path>season</Path><Name>Season</Name><Value/><Unit/><PerUnit/><ItemValueDefinition uid="527AADFB3B65"><Path>season</Path><Name>Season</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="AE5413F7A459"><Path>includesHeating</Path><Name>Includes Heating</Name><Value>false</Value><Unit/><PerUnit/><ItemValueDefinition uid="1740E500BDAB"><Path>includesHeating</Path><Name>Includes Heating</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="20FC928B045A"><Path>massPerTime</Path><Name>Mass Per Time</Name><Value/><Unit>kg</Unit><PerUnit>year</PerUnit><ItemValueDefinition uid="80F561BE56E2"><Path>massPerTime</Path><Name>Mass Per Time</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kg</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="3835DF705F9D"><Path>energyConsumption</Path><Name>Energy Consumption</Name><Value>13</Value><Unit>kWh</Unit><PerUnit>month</PerUnit><ItemValueDefinition uid="9801C6552128"><Path>energyConsumption</Path><Name>Energy Consumption</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="064C0DB99F75"><Path>currentReading</Path><Name>Current Reading</Name><Value/><Unit>kWh</Unit><PerUnit/><ItemValueDefinition uid="6EF1FF3361F0"><Path>currentReading</Path><Name>Current Reading</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="06B35B089155"><Path>lastReading</Path><Name>Last Reading</Name><Value/><Unit>kWh</Unit><PerUnit/><ItemValueDefinition uid="7DDB0BB0B6CA"><Path>lastReading</Path><Name>Last Reading</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="CEBEA6C086B8"><Path>volumePerTime</Path><Name>Volume Per Time</Name><Value/><Unit>L</Unit><PerUnit>year</PerUnit><ItemValueDefinition uid="CDA01AFCF91B"><Path>volumePerTime</Path><Name>Volume Per Time</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>L</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="0E77ACB084A5"><Path>deliveries</Path><Name>Number of deliveries</Name><Value/><Unit>year</Unit><PerUnit/><ItemValueDefinition uid="DEB369A7AD4E"><Path>deliveries</Path><Name>Number of deliveries</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>year</Unit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue></ItemValues><Amount unit="kg/year">29.664</Amount><Amounts><Amount default="true" perUnit="year" type="CO2" unit="kg">29.664</Amount></Amounts><StartDate>2008-09-02T01:00+0100</StartDate><EndDate/><DataItem uid="66056991EE23"><Label>gas</Label></DataItem></ProfileItem><ProfileItem created="2009-02-11T14:13+0000" modified="2009-02-11T14:13+0000" uid="BC0B730255FB"><Name>BC0B730255FB</Name><ItemValues><ItemValue uid="C3DEE5535925"><Path>paymentFrequency</Path><Name>Payment frequency</Name><Value/><Unit/><PerUnit/><ItemValueDefinition uid="E0EFED6FD7E6"><Path>paymentFrequency</Path><Name>Payment frequency</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="DFBD9254685A"><Path>greenTariff</Path><Name>Green tariff</Name><Value/><Unit/><PerUnit/><ItemValueDefinition uid="63005554AE8A"><Path>greenTariff</Path><Name>Green tariff</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="CB8705EB55C5"><Path>season</Path><Name>Season</Name><Value/><Unit/><PerUnit/><ItemValueDefinition uid="527AADFB3B65"><Path>season</Path><Name>Season</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="A282A7875AEB"><Path>includesHeating</Path><Name>Includes Heating</Name><Value>false</Value><Unit/><PerUnit/><ItemValueDefinition uid="1740E500BDAB"><Path>includesHeating</Path><Name>Includes Heating</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="2624A9954F17"><Path>massPerTime</Path><Name>Mass Per Time</Name><Value/><Unit>kg</Unit><PerUnit>year</PerUnit><ItemValueDefinition uid="80F561BE56E2"><Path>massPerTime</Path><Name>Mass Per Time</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kg</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="44518F8EC8DC"><Path>energyConsumption</Path><Name>Energy Consumption</Name><Value/><Unit>kWh</Unit><PerUnit>year</PerUnit><ItemValueDefinition uid="9801C6552128"><Path>energyConsumption</Path><Name>Energy Consumption</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="C97FDB7CE8DF"><Path>currentReading</Path><Name>Current Reading</Name><Value/><Unit>kWh</Unit><PerUnit/><ItemValueDefinition uid="6EF1FF3361F0"><Path>currentReading</Path><Name>Current Reading</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="B540FB4C05C7"><Path>lastReading</Path><Name>Last Reading</Name><Value/><Unit>kWh</Unit><PerUnit/><ItemValueDefinition uid="7DDB0BB0B6CA"><Path>lastReading</Path><Name>Last Reading</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="32A873ED2142"><Path>volumePerTime</Path><Name>Volume Per Time</Name><Value/><Unit>L</Unit><PerUnit>year</PerUnit><ItemValueDefinition uid="CDA01AFCF91B"><Path>volumePerTime</Path><Name>Volume Per Time</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>L</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue><ItemValue uid="88C0DC759E16"><Path>deliveries</Path><Name>Number of deliveries</Name><Value/><Unit>year</Unit><PerUnit/><ItemValueDefinition uid="DEB369A7AD4E"><Path>deliveries</Path><Name>Number of deliveries</Name><ValueDefinition created="2007-07-27 09:30:44.0" modified="2007-07-27 09:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DOUBLE</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>year</Unit><FromProfile>true</FromProfile><FromData>false</FromData></ItemValueDefinition></ItemValue></ItemValues><Amount unit="kg/year">0.000</Amount><StartDate>2009-02-11T14:13+0000</StartDate><EndDate/><DataItem uid="A70149AF0F26"><Label>coal</Label></DataItem></ProfileItem></ProfileItems><Pager><Start>0</Start><From>1</From><To>2</To><Items>2</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>2</ItemsFound></Pager><TotalAmount unit="kg/year">1265.664</TotalAmount></ProfileCategoryResource></Resources>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/26532D8EFA9D/home/energy/quantity")
    @cat.total_amount.should be_within(1.0e-09).of(1265.664)
    @cat.total_amount_unit.should == "kg/year"
    @cat.items.size.should be(2)
    @cat.items[0][:uid].should == "30C00AD33033"
    @cat.items[0][:name].should == "gas"
    @cat.items[0][:path].should == "30C00AD33033"
    @cat.items[0][:dataItemLabel].should == "gas"
    @cat.items[0][:dataItemUid].should == "66056991EE23"
    @cat.items[0][:startDate].should == DateTime.new(2008, 9, 2)
    @cat.items[0][:endDate].should be_nil
    @cat.items[0][:amount].should be_within(1.0e-09).of(29.664)
    @cat.items[0][:amount_unit].should == "kg/year"
    @cat.items[0][:values].size.should be(10)
    @cat.items[0][:values][:energyConsumption][:value].should == "13"
    @cat.items[0][:values][:energyConsumption][:unit].should == "kWh"
    @cat.items[0][:values][:energyConsumption][:per_unit].should == "month"
    @cat.items[0][:values][:massPerTime][:value].should == "0"
    @cat.items[0][:values][:volumePerTime][:value].should == "0"
    @cat.pager.should_not be_nil
  end

  it "should parse multiple return values" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    connection.should_receive(:get).with("/profiles/F8C2D1052BF7/home/energy/quantity", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8" standalone="no"?><Resources xmlns="http://schemas.amee.cc/2.0"><ProfileCategoryResource><Path>/home/energy/quantity</Path><Profile uid="F8C2D1052BF7"/><Environment created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="5F5887BCF726"><Name>AMEE</Name><Path/><Description/><Owner/><ItemsPerPage>10</ItemsPerPage><ItemsPerFeed>10</ItemsPerFeed></Environment><DataCategory uid="A92693A99BAD"><Name>Quantity</Name><Path>quantity</Path><Deprecated>false</Deprecated></DataCategory><ProfileCategories/><ProfileItems><ProfileItem created="2010-07-16T14:44:43Z" modified="2010-07-16T14:45:03Z" uid="3BCDB0BB2B96"><Name>gas</Name><ItemValues><ItemValue uid="06F553CED9F7"><Path>currentReading</Path><Name>Current Reading</Name><Value>0</Value><Unit>kWh</Unit><PerUnit>year</PerUnit><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="67B7476423C0"><Path>currentReading</Path><Name>Current Reading</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue><ItemValue uid="4CF7691084DB"><Path>energyConsumption</Path><Name>Energy Consumption</Name><Value>13</Value><Unit>kWh</Unit><PerUnit>month</PerUnit><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="068A0D6D03F7"><Path>energyConsumption</Path><Name>Energy Consumption</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue><ItemValue uid="1CA0D40208F0"><Path>includesHeating</Path><Name>Includes Heating</Name><Value>false</Value><Unit/><PerUnit/><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="1740E500BDAB"><Path>includesHeating</Path><Name>Includes Heating</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue><ItemValue uid="1ACEB4784A42"><Path>season</Path><Name>Season</Name><Value/><Unit/><PerUnit/><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="527AADFB3B65"><Path>season</Path><Name>Season</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue><ItemValue uid="036262B5D69D"><Path>greenTariff</Path><Name>Green tariff</Name><Value/><Unit/><PerUnit/><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="63005554AE8A"><Path>greenTariff</Path><Name>Green tariff</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue><ItemValue uid="A568643CD1D7"><Path>paymentFrequency</Path><Name>Payment frequency</Name><Value/><Unit/><PerUnit/><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="E0EFED6FD7E6"><Path>paymentFrequency</Path><Name>Payment frequency</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="CCEB59CACE1B"><Name>text</Name><ValueType>TEXT</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue><ItemValue uid="990F69A6BD48"><Path>massPerTime</Path><Name>Mass Per Time</Name><Value>0</Value><Unit>kg</Unit><PerUnit>year</PerUnit><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="CF12B3EBAD02"><Path>massPerTime</Path><Name>Mass Per Time</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kg</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue><ItemValue uid="A5BB73E6CBD2"><Path>lastReading</Path><Name>Last Reading</Name><Value>0</Value><Unit>kWh</Unit><PerUnit>year</PerUnit><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="40AB7E90980C"><Path>lastReading</Path><Name>Last Reading</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>kWh</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue><ItemValue uid="DA93374B62C2"><Path>volumePerTime</Path><Name>Volume Per Time</Name><Value>0</Value><Unit>L</Unit><PerUnit>year</PerUnit><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="324EC808AC30"><Path>volumePerTime</Path><Name>Volume Per Time</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><Unit>L</Unit><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue><ItemValue uid="FA09F1FF043D"><Path>deliveries</Path><Name>Number of deliveries</Name><Value/><Unit/><PerUnit>year</PerUnit><StartDate>2010-07-16T10:44:00-04:00</StartDate><ItemValueDefinition uid="177D4642A07A"><Path>deliveries</Path><Name>Number of deliveries</Name><ValueDefinition created="2007-07-27 08:30:44.0" modified="2007-07-27 08:30:44.0" uid="45433E48B39F"><Name>amount</Name><ValueType>DECIMAL</ValueType><Description/><Environment uid="5F5887BCF726"/></ValueDefinition><PerUnit>year</PerUnit><FromProfile>true</FromProfile><FromData>false</FromData><DrillDown>false</DrillDown></ItemValueDefinition></ItemValue></ItemValues><Amount unit="kg/year">31.7772</Amount><Amounts><Amount default="true" perUnit="year" type="CO2" unit="kg">31.7772</Amount><Amount type="CH4" unit="kg">4.2</Amount><Note type="comment">This is a text node</Note><Note type="comment">This is another text node</Note></Amounts><StartDate>2010-07-16T10:44:00-04:00</StartDate><EndDate/><DataItem uid="66056991EE23"><Label>gas</Label></DataItem></ProfileItem></ProfileItems><Pager><Start>0</Start><From>1</From><To>1</To><Items>1</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>1</ItemsFound></Pager><TotalAmount unit="kg/year">31.7772</TotalAmount></ProfileCategoryResource></Resources>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/F8C2D1052BF7/home/energy/quantity")
    @cat.total_amount.should be_within(0.0001).of(31.7772)
    @cat.total_amount_unit.should == 'kg/year'
    item = @cat.items[0]
    item[:amounts].size.should be(2)
    item[:amounts][0][:type].should == "CO2"
    item[:amounts][0][:value].should be_within(0.0001).of(31.7772)
    item[:amounts][0][:unit].should == 'kg'
    item[:amounts][0][:per_unit].should == 'year'
    item[:amounts][0][:default].should be_true
    item[:amounts][1][:type].should == "CH4"
    item[:amounts][1][:value].should be_within(1e-2).of(4.2)
    item[:amounts][1][:unit].should == 'kg'
    item[:amounts][1][:per_unit].should be_nil
    item[:notes].size.should be(2)
    item[:notes][0][:type].should == 'comment'
    item[:notes][0][:value].should == 'This is a text node'
    item[:notes][1][:type].should == 'comment'
    item[:notes][1][:value].should == 'This is another text node'
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources xmlns="http://schemas.amee.cc/2.0"></Resources>'
    connection.should_receive(:get).with("/profiles/E54C5525AA3E", {}).and_return(flexmock(:body => xml))
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData)
  end

#  it "parses recursive GET requests" do
#    connection = flexmock "connection"
#    connection.should_receive(:version).and_return(2.0)
#   connection.should_receive(:get).with("/profiles/BE22C1732952/transport/car", {:recurse=>true}).and_return('')
#    cat = AMEE::Profile::Category.get(connection, "/profiles/BE22C1732952/transport/car", :recurse => true)
#    cat.items.size.should == 0
#    cat.children.size.should == 3
#    cat.children[1][:name].should == "Generic"
#    cat.children[1][:path].should == "generic"
#    cat.children[1][:uid].should == "87E55DA88017"
#    cat.children[1][:totalAmountPerMonth].should == 0.265
#    cat.children[1][:children].size.should == 1
#    cat.children[1][:children][0][:name].should == "Electric"
#    cat.children[1][:children][0][:path].should == "electric"
#    cat.children[1][:children][0][:uid].should == "417DD367E9AA"
#    cat.children[1][:items].size.should == 1
#    cat.children[1][:items][0][:amountPerMonth].should == 0.265
#    cat.children[1][:items][0][:dataItemLabel].should == "diesel, large"
#    cat.children[1][:items][0][:dataItemUid].should == "4F6CBCEE95F7"
#    cat.children[1][:items][0][:values][:airconTypical].should == "true"
#    cat.children[1][:items][0][:uid].should == "8450D6D97D2D"
#  end

end

describe AMEE::Profile::Category, "with an authenticated version 2 Atom connection" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    connection.should_receive(:get).with("/profiles/FD89B8D07D4F/home", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?> <feed xmlns="http://www.w3.org/2005/Atom" xmlns:amee="http://schemas.amee.cc/2.0" xml:lang="en-US" xml:base="http://dev.amee.com/profiles/FD89B8D07D4F/home"> <title type="text">Profile FD89B8D07D4F, Category Home</title> <id>urn:dataCategory:BBA3AC3E795E</id> <generator version="2.0" uri="http://www.amee.cc">AMEE</generator> <link href="" type="application/atom+xml" rel="edit" /> <link href="" type="application/json" rel="alternate" /> <link href="" type="application/xml" rel="alternate" /> <author> <name>FD89B8D07D4F</name> </author> <amee:name>Home</amee:name> <amee:totalAmount unit="kg/year">0.000000</amee:totalAmount> <updated>1970-01-01T00:00:00.000Z</updated> </feed>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/FD89B8D07D4F/home")
    @cat.profile_uid.should == "FD89B8D07D4F"
    @cat.name.should == "Home"
    @cat.path.should == "/home"
    @cat.full_path.should == "/profiles/FD89B8D07D4F/home"
    #@cat.children.size.should be(6)
    #@cat.children[0][:uid].should == "427DFCC65E52"
    #@cat.children[0][:name].should == "Appliances"
    #@cat.children[0][:path].should == "appliances"
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    connection.should_receive(:get).with("/profiles/9BFB0C1CD78A/home/energy/quantity", {}).and_return(flexmock(:body => '<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:amee="http://schemas.amee.cc/2.0" xml:lang="en-US" xml:base="http://dev.amee.com/profiles/9BFB0C1CD78A/home/energy/quantity"><title type="text">Profile 9BFB0C1CD78A, Category /home/energy/quantity</title><id>urn:dataCategory:A92693A99BAD</id><generator version="2.0" uri="http://www.amee.cc">AMEE</generator><link href="" type="application/atom+xml" rel="edit" /><link href="" type="application/json" rel="alternate" /><link href="" type="application/xml" rel="alternate" /><author><name>9BFB0C1CD78A</name></author><amee:name>Quantity</amee:name><amee:totalAmount unit="kg/year">1265.664</amee:totalAmount><updated>2009-02-11T14:13:28.000Z</updated><entry><title type="text">gas</title><subtitle type="text">Tue, 2 Sep 2008 01:00:00 BST</subtitle><link href="30C00AD33033" type="application/atom+xml" rel="edit" /><link href="30C00AD33033" type="application/json" rel="alternate" /><link href="30C00AD33033" type="application/xml" rel="alternate" /><id>urn:item:30C00AD33033</id><published>2008-09-02T00:00:00.000Z</published><updated>2008-09-02T00:00:00.000Z</updated><amee:startDate>2008-09-02T01:00+0100</amee:startDate><amee:amount unit="kg/year">29.664</amee:amount><amee:itemValue><amee:name>Payment frequency</amee:name><amee:value>N/A</amee:value><link href="30C00AD33033/paymentFrequency" rel="http://schemas.amee.cc/2.0#itemValue" /></amee:itemValue><amee:itemValue><amee:name>Green tariff</amee:name><amee:value>N/A</amee:value><link href="30C00AD33033/greenTariff" rel="http://schemas.amee.cc/2.0#itemValue" /></amee:itemValue><amee:itemValue><amee:name>Season</amee:name><amee:value>N/A</amee:value><link href="30C00AD33033/season" rel="http://schemas.amee.cc/2.0#itemValue" /></amee:itemValue><amee:itemValue><amee:name>Includes Heating</amee:name><amee:value>false</amee:value><link href="30C00AD33033/includesHeating" rel="http://schemas.amee.cc/2.0#itemValue" /></amee:itemValue><amee:itemValue><amee:name>Mass Per Time</amee:name><amee:value>N/A</amee:value><link href="30C00AD33033/massPerTime" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>kg</amee:unit><amee:perUnit>year</amee:perUnit></amee:itemValue><amee:itemValue><amee:name>Energy Consumption</amee:name><amee:value>13</amee:value><link href="30C00AD33033/energyConsumption" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>kWh</amee:unit><amee:perUnit>month</amee:perUnit></amee:itemValue><amee:itemValue><amee:name>Current Reading</amee:name><amee:value>N/A</amee:value><link href="30C00AD33033/currentReading" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>kWh</amee:unit></amee:itemValue><amee:itemValue><amee:name>Last Reading</amee:name><amee:value>N/A</amee:value><link href="30C00AD33033/lastReading" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>kWh</amee:unit></amee:itemValue><amee:itemValue><amee:name>Volume Per Time</amee:name><amee:value>N/A</amee:value><link href="30C00AD33033/volumePerTime" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>L</amee:unit><amee:perUnit>year</amee:perUnit></amee:itemValue><amee:itemValue><amee:name>Number of deliveries</amee:name><amee:value>N/A</amee:value><link href="30C00AD33033/deliveries" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>year</amee:unit></amee:itemValue><amee:name>gas</amee:name><content type="html">&lt;div class="vevent">&lt;div class="summary">0.000 kg/year&lt;/div>&lt;abbr class="dtstart" title="2008-09-02T01:00+0100"> Tue, 2 Sep 2008 01:00:00 BST&lt;/abbr>&lt;/div></content><category scheme="http://schemas.amee.cc/2.0#item" term="66056991EE23" label="Energy Quantity" /></entry><entry><title type="text">BC0B730255FB</title><subtitle type="text">Wed, 11 Feb 2009 14:13:00 GMT</subtitle><link href="BC0B730255FB" type="application/atom+xml" rel="edit" /><link href="BC0B730255FB" type="application/json" rel="alternate" /><link href="BC0B730255FB" type="application/xml" rel="alternate" /><id>urn:item:BC0B730255FB</id><published>2009-02-11T14:13:00.000Z</published><updated>2009-02-11T14:13:00.000Z</updated><amee:startDate>2009-02-11T14:13+0000</amee:startDate><amee:amount unit="kg/year">0.000</amee:amount><amee:itemValue><amee:name>Payment frequency</amee:name><amee:value>N/A</amee:value><link href="BC0B730255FB/paymentFrequency" rel="http://schemas.amee.cc/2.0#itemValue" /></amee:itemValue><amee:itemValue><amee:name>Green tariff</amee:name><amee:value>N/A</amee:value><link href="BC0B730255FB/greenTariff" rel="http://schemas.amee.cc/2.0#itemValue" /></amee:itemValue><amee:itemValue><amee:name>Season</amee:name><amee:value>N/A</amee:value><link href="BC0B730255FB/season" rel="http://schemas.amee.cc/2.0#itemValue" /></amee:itemValue><amee:itemValue><amee:name>Includes Heating</amee:name><amee:value>false</amee:value><link href="BC0B730255FB/includesHeating" rel="http://schemas.amee.cc/2.0#itemValue" /></amee:itemValue><amee:itemValue><amee:name>Mass Per Time</amee:name><amee:value>N/A</amee:value><link href="BC0B730255FB/massPerTime" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>kg</amee:unit><amee:perUnit>year</amee:perUnit></amee:itemValue><amee:itemValue><amee:name>Energy Consumption</amee:name><amee:value>N/A</amee:value><link href="BC0B730255FB/energyConsumption" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>kWh</amee:unit><amee:perUnit>year</amee:perUnit></amee:itemValue><amee:itemValue><amee:name>Current Reading</amee:name><amee:value>N/A</amee:value><link href="BC0B730255FB/currentReading" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>kWh</amee:unit></amee:itemValue><amee:itemValue><amee:name>Last Reading</amee:name><amee:value>N/A</amee:value><link href="BC0B730255FB/lastReading" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>kWh</amee:unit></amee:itemValue><amee:itemValue><amee:name>Volume Per Time</amee:name><amee:value>N/A</amee:value><link href="BC0B730255FB/volumePerTime" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>L</amee:unit><amee:perUnit>year</amee:perUnit></amee:itemValue><amee:itemValue><amee:name>Number of deliveries</amee:name><amee:value>N/A</amee:value><link href="BC0B730255FB/deliveries" rel="http://schemas.amee.cc/2.0#itemValue" /><amee:unit>year</amee:unit></amee:itemValue><amee:name></amee:name><content type="html">&lt;div class="vevent">&lt;div class="summary">0.000 kg/year&lt;/div>&lt;abbr class="dtstart" title="2009-02-11T14:13+0000"> Wed, 11 Feb 2009 14:13:00 GMT&lt;/abbr>&lt;/div></content><category scheme="http://schemas.amee.cc/2.0#item" term="A70149AF0F26" label="Energy Quantity" /></entry></feed>'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/9BFB0C1CD78A/home/energy/quantity")
    @cat.total_amount.should be_within(1.0e-09).of(1265.664)
    @cat.total_amount_unit.should == "kg/year"
    @cat.items.size.should be(2)
    @cat.items[0][:uid].should == "30C00AD33033"
    @cat.items[0][:name].should == "gas"
    @cat.items[0][:path].should == "30C00AD33033"
    #@cat.items[0][:dataItemLabel].should == "gas"
    #@cat.items[0][:dataItemUid].should == "66056991EE23"
    @cat.items[0][:startDate].should == DateTime.new(2008, 9, 2)
    @cat.items[0][:endDate].should be_nil
    @cat.items[0][:amount].should be_within(1.0e-09).of(29.664)
    @cat.items[0][:amount_unit].should == "kg/year"
    @cat.items[0][:values].size.should be(10)
    @cat.items[0][:values][:energyConsumption][:value].should == "13"
    @cat.items[0][:values][:energyConsumption][:unit].should == "kWh"
    @cat.items[0][:values][:energyConsumption][:per_unit].should == "month"
    @cat.items[0][:values][:massPerTime][:value].should == "0"
    @cat.items[0][:values][:volumePerTime][:value].should == "0"
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    atom = '<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:amee="http://schemas.amee.cc/2.0"></feed>'
    connection.should_receive(:get).with("/profiles/E54C5525AA3E", {}).and_return(flexmock(:body => atom))
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData)
  end

#  it "parses recursive GET requests" do
#    connection = flexmock "connection"
#    connection.should_receive(:version).and_return(2.0)
#    connection.should_receive(:get).with("/profiles/BE22C1732952/transport/car", {:recurse=>true}).and_return(flexmock(:body => ''))
#    cat = AMEE::Profile::Category.get(connection, "/profiles/BE22C1732952/transport/car", :recurse => true)
#    cat.items.size.should == 0
#    cat.children.size.should == 3
#    cat.children[1][:name].should == "Generic"
#    cat.children[1][:path].should == "generic"
#    cat.children[1][:uid].should == "87E55DA88017"
#    cat.children[1][:totalAmountPerMonth].should == 0.265
#    cat.children[1][:children].size.should == 1
#    cat.children[1][:children][0][:name].should == "Electric"
#    cat.children[1][:children][0][:path].should == "electric"
#    cat.children[1][:children][0][:uid].should == "417DD367E9AA"
#    cat.children[1][:items].size.should == 1
#    cat.children[1][:items][0][:amountPerMonth].should == 0.265
#    cat.children[1][:items][0][:dataItemLabel].should == "diesel, large"
#    cat.children[1][:items][0][:dataItemUid].should == "4F6CBCEE95F7"
#    cat.children[1][:items][0][:values][:airconTypical].should == "true"
#    cat.children[1][:items][0][:uid].should == "8450D6D97D2D"
#  end

end

describe AMEE::Profile::Category, "with an authenticated JSON connection" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home", {}).and_return(flexmock(:body => '{"totalAmountPerMonth":"0","dataCategory":{"uid":"BBA3AC3E795E","path":"home","name":"Home"},"profileDate":"200809","path":"/home","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{},"dataCategories":[{"uid":"427DFCC65E52","path":"appliances","name":"Appliances"},{"uid":"30BA55A0C472","path":"energy","name":"Energy"},{"uid":"A46ECFA19333","path":"heating","name":"Heating"},{"uid":"150266DD4434","path":"lighting","name":"Lighting"}],"profileItems":{}}}'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home")
    @cat.profile_uid.should == "E54C5525AA3E"
    @cat.profile_date.should == DateTime.new(2008, 9)
    @cat.name.should == "Home"
    @cat.path.should == "/home"
    @cat.full_path.should == "/profiles/E54C5525AA3E/home"
    @cat.children.size.should be(4)
    @cat.children[0][:uid].should == "427DFCC65E52"
    @cat.children[0][:name].should == "Appliances"
    @cat.children[0][:path].should == "appliances"
    @cat.pager.should be_nil
  end

  it "should provide access to child objects" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home", {}).and_return(flexmock(:body => '{"totalAmountPerMonth":"0","dataCategory":{"uid":"BBA3AC3E795E","path":"home","name":"Home"},"profileDate":"200809","path":"/home","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{},"dataCategories":[{"uid":"427DFCC65E52","path":"appliances","name":"Appliances"},{"uid":"30BA55A0C472","path":"energy","name":"Energy"},{"uid":"A46ECFA19333","path":"heating","name":"Heating"},{"uid":"150266DD4434","path":"lighting","name":"Lighting"}],"profileItems":{}}}'))
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/appliances", {}).and_return(flexmock(:body => '{"totalAmountPerMonth":"0","dataCategory":{"uid":"427DFCC65E52","path":"appliances","name":"Appliances"},"profileDate":"200809","path":"/home/appliances","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{},"dataCategories":[{"uid":"3FE23FDC8CEA","path":"computers","name":"Computers"},{"uid":"54C8A44254AA","path":"cooking","name":"Cooking"},{"uid":"75AD9B83B7BF","path":"entertainment","name":"Entertainment"},{"uid":"4BD595E1873A","path":"kitchen","name":"Kitchen"},{"uid":"700D0771870A","path":"televisions","name":"Televisions"}],"profileItems":{}}}'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home")
    @child = @cat.child('appliances')
    @child.path.should == "/home/appliances"
    @child.full_path.should == "/profiles/E54C5525AA3E/home/appliances"
    @child.children.size.should be(5)
    @child.pager.should be_nil
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/energy/quantity", {}).and_return(flexmock(:body => '{"totalAmountPerMonth":105.472,"dataCategory":{"uid":"A92693A99BAD","path":"quantity","name":"Quantity"},"profileDate":"200809","path":"/home/energy/quantity","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{"to":2,"lastPage":1,"start":0,"nextPage":-1,"items":2,"itemsPerPage":10,"from":1,"previousPage":-1,"requestedPage":1,"currentPage":1,"itemsFound":2},"dataCategories":[],"profileItems":{"rows":[{"created":"2008-09-03 11:37:35.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"FB07247AD937","modified":"2008-09-03 11:38:12.0","dataItemUid":"66056991EE23","validFrom":"20080902","amountPerMonth":"2.472","label":"ProfileItem","litresPerMonth":"0","path":"FB07247AD937","kWhPerMonth":"12","name":"gas"},{"created":"2008-09-03 11:40:44.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"D9CBCDED44C5","modified":"2008-09-03 11:41:54.0","dataItemUid":"66056991EE23","validFrom":"20080901","amountPerMonth":"103.000","label":"ProfileItem","litresPerMonth":"0","path":"D9CBCDED44C5","kWhPerMonth":"500","name":"gas2"}],"label":"ProfileItems"}}}'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home/energy/quantity")
    @cat.total_amount.should be_within(1.0e-09).of(105.472)
    @cat.total_amount_unit.should == "kg/month"
    @cat.items.size.should be(2)
    @cat.items[0][:uid].should == "FB07247AD937"
    @cat.items[0][:name].should == "gas"
    @cat.items[0][:path].should == "FB07247AD937"
    @cat.items[0][:dataItemLabel].should == "gas"
    @cat.items[0][:dataItemUid].should == "66056991EE23"
    @cat.items[0][:validFrom].should == DateTime.new(2008, 9, 2)
    @cat.items[0][:end].should == false
    @cat.items[0][:amountPerMonth].should be_within(1.0e-09).of(2.472)
    @cat.items[0][:values].size.should be(3)
    @cat.items[0][:values][:kWhPerMonth].should == "12"
    @cat.items[0][:values][:kgPerMonth].should == "0"
    @cat.items[0][:values][:litresPerMonth].should == "0"
    @cat.pager.should_not be_nil
 end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    json = '{"apiVersion":"2.0"}'
    connection.should_receive(:get).with("/profiles/E54C5525AA3E", {}).and_return(flexmock(:body => json))
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData)
  end

  it "parses recursive GET requests" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(1.0)
    connection.should_receive(:get).with("/profiles/BE22C1732952/transport/car", {:recurse => true}).and_return(flexmock(:body => '{"totalAmountPerMonth":"0","dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"profileDate":"200901","path":"/transport/car","profile":{"uid":"BE22C1732952"},"children":{"pager":{},"dataCategories":[{"dataCategory":{"modified":"2008-04-21 16:42:10.0","created":"2008-04-21 16:42:10.0","itemDefinition":{"uid":"C6BC60C55678"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"883ADD27228F","environment":{"uid":"5F5887BCF726"},"path":"bands","name":"Bands"},"path":"/transport/car/bands"},{"totalAmountPerMonth":0.265,"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","itemDefinition":{"uid":"123C4A18B5D6"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"87E55DA88017","environment":{"uid":"5F5887BCF726"},"path":"generic","name":"Generic"},"path":"/transport/car/generic","children":{"dataCategories":[{"dataCategory":{"modified":"2008-09-23 12:18:03.0","created":"2008-09-23 12:18:03.0","itemDefinition":{"uid":"E6D0BB09578A"},"dataCategory":{"uid":"87E55DA88017","path":"generic","name":"Generic"},"uid":"417DD367E9AA","environment":{"uid":"5F5887BCF726"},"path":"electric","name":"Electric"},"path":"/transport/car/generic/electric"}],"profileItems":{"rows":[{"created":"2009-01-05 13:58:52.0","ecoDriving":"false","tyresUnderinflated":"false","dataItemLabel":"diesel, large","kmPerLitre":"0","distanceKmPerMonth":"1","end":"false","uid":"8450D6D97D2D","modified":"2009-01-05 13:59:05.0","airconFull":"false","dataItemUid":"4F6CBCEE95F7","validFrom":"20090101","amountPerMonth":"0.265","kmPerLitreOwn":"0","country":"","label":"ProfileItem","occupants":"-1","airconTypical":"true","path":"8450D6D97D2D","name":"","regularlyServiced":"true"}],"label":"ProfileItems"}}},{"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","itemDefinition":{"uid":"07EBA32512DF"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"95E76249584D","environment":{"uid":"5F5887BCF726"},"path":"specific","name":"Specific"},"path":"/transport/car/specific"}],"profileItems":{}}}'))
    cat = AMEE::Profile::Category.get(connection, "/profiles/BE22C1732952/transport/car", :recurse => true)
    cat.items.size.should == 0
    cat.children.size.should == 3
    cat.children[1][:name].should == "Generic"
    cat.children[1][:path].should == "generic"
    cat.children[1][:uid].should == "87E55DA88017"
    cat.children[1][:totalAmountPerMonth].should == 0.265
    cat.children[1][:children].size.should == 1
    cat.children[1][:children][0][:name].should == "Electric"
    cat.children[1][:children][0][:path].should == "electric"
    cat.children[1][:children][0][:uid].should == "417DD367E9AA"
    cat.children[1][:items].size.should == 1
    cat.children[1][:items][0][:amountPerMonth].should == 0.265
    cat.children[1][:items][0][:dataItemLabel].should == "diesel, large"
    cat.children[1][:items][0][:dataItemUid].should == "4F6CBCEE95F7"
    cat.children[1][:items][0][:values][:airconTypical].should == "true"
    cat.children[1][:items][0][:uid].should == "8450D6D97D2D"
    cat.pager.should be_nil
  end

end

describe AMEE::Profile::Category, "with an authenticated V2 JSON connection" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    connection.should_receive(:get).with("/profiles/447C40EB29FB/home", {}).and_return(flexmock(:body => '{"apiVersion":"2.0","pager":{},"profileCategories":[{"uid":"427DFCC65E52","name":"Appliances","path":"appliances"},{"uid":"30BA55A0C472","name":"Energy","path":"energy"},{"uid":"A46ECFA19333","name":"Heating","path":"heating"},{"uid":"150266DD4434","name":"Lighting","path":"lighting"},{"uid":"6553150F96CE","name":"Waste","path":"waste"},{"uid":"07362DCC9E7B","name":"Water","path":"water"}],"dataCategory":{"uid":"BBA3AC3E795E","dataCategory":{"uid":"CD310BEBAC52","name":"Root","path":""},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10},"created":"2007-07-27 09:30:44.0","name":"Home","path":"home","modified":"2007-07-27 09:30:44.0"},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"created":"2007-07-27 09:30:44.0","description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10,"modified":"2007-07-27 09:30:44.0"},"totalAmount":"0","path":"/home","profileItemActions":{"allowCreate":true,"allowView":true,"allowList":true,"allowModify":true,"allowDelete":true},"actions":{"allowCreate":true,"allowView":true,"allowList":true,"allowModify":true,"allowDelete":true},"profileItems":{},"profile":{"uid":"447C40EB29FB"}}'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/447C40EB29FB/home")
    @cat.profile_uid.should == "447C40EB29FB"
    @cat.name.should == "Home"
    @cat.path.should == "/home"
    @cat.full_path.should == "/profiles/447C40EB29FB/home"
    @cat.children.size.should be(6)
    @cat.children[0][:uid].should == "427DFCC65E52"
    @cat.children[0][:name].should == "Appliances"
    @cat.children[0][:path].should == "appliances"
    @cat.pager.should be_nil
  end

  it "should provide access to child objects" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    connection.should_receive(:get).with("/profiles/447C40EB29FB/home", {}).and_return(flexmock(:body => '{"apiVersion":"2.0","pager":{},"profileCategories":[{"uid":"427DFCC65E52","name":"Appliances","path":"appliances"},{"uid":"30BA55A0C472","name":"Energy","path":"energy"},{"uid":"A46ECFA19333","name":"Heating","path":"heating"},{"uid":"150266DD4434","name":"Lighting","path":"lighting"},{"uid":"6553150F96CE","name":"Waste","path":"waste"},{"uid":"07362DCC9E7B","name":"Water","path":"water"}],"dataCategory":{"uid":"BBA3AC3E795E","dataCategory":{"uid":"CD310BEBAC52","name":"Root","path":""},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10},"created":"2007-07-27 09:30:44.0","name":"Home","path":"home","modified":"2007-07-27 09:30:44.0"},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"created":"2007-07-27 09:30:44.0","description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10,"modified":"2007-07-27 09:30:44.0"},"totalAmount":"0","path":"/home","profileItemActions":{"allowCreate":true,"allowView":true,"allowList":true,"allowModify":true,"allowDelete":true},"actions":{"allowCreate":true,"allowView":true,"allowList":true,"allowModify":true,"allowDelete":true},"profileItems":{},"profile":{"uid":"447C40EB29FB"}}'))
    connection.should_receive(:get).with("/profiles/447C40EB29FB/home/appliances", {}).and_return(flexmock(:body => '{"apiVersion":"2.0","pager":{},"profileCategories":[{"uid":"3FE23FDC8CEA","name":"Computers","path":"computers"},{"uid":"54C8A44254AA","name":"Cooking","path":"cooking"},{"uid":"75AD9B83B7BF","name":"Entertainment","path":"entertainment"},{"uid":"4BD595E1873A","name":"Kitchen","path":"kitchen"},{"uid":"700D0771870A","name":"Televisions","path":"televisions"}],"dataCategory":{"uid":"427DFCC65E52","dataCategory":{"uid":"BBA3AC3E795E","name":"Home","path":"home"},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10},"created":"2007-07-27 09:30:44.0","name":"Appliances","path":"appliances","modified":"2007-07-27 09:30:44.0"},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"created":"2007-07-27 09:30:44.0","description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10,"modified":"2007-07-27 09:30:44.0"},"totalAmount":"0","path":"/home/appliances","profileItemActions":{"allowCreate":true,"allowView":true,"allowList":true,"allowModify":true,"allowDelete":true},"actions":{"allowCreate":true,"allowView":true,"allowList":true,"allowModify":true,"allowDelete":true},"profileItems":{},"profile":{"uid":"447C40EB29FB"}}'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/447C40EB29FB/home")
    @child = @cat.child('appliances')
    @child.path.should == "/home/appliances"
    @child.full_path.should == "/profiles/447C40EB29FB/home/appliances"
    @child.children.size.should be(5)
    @child.pager.should be_nil
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    connection.should_receive(:get).with("/profiles/447C40EB29FB/home/energy/quantity", {}).and_return(flexmock(:body => '{"apiVersion":"2.0","pager":{"to":1,"lastPage":1,"nextPage":-1,"items":1,"start":0,"itemsFound":1,"requestedPage":1,"currentPage":1,"from":1,"itemsPerPage":10,"previousPage":-1},"profileCategories":[],"dataCategory":{"uid":"A92693A99BAD","dataCategory":{"uid":"30BA55A0C472","deprecated":false,"name":"Energy","path":"energy"},"deprecated":false,"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10},"created":"2007-07-27 08:30:44.0","name":"Quantity","path":"quantity","itemDefinition":{"uid":"212C818D8F16","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","name":"Energy Quantity","drillDown":"type","modified":"2007-07-27 08:30:44.0"},"modified":"2007-07-27 08:30:44.0"},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"created":"2007-07-27 08:30:44.0","description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10,"modified":"2007-07-27 08:30:44.0"},"totalAmount":{"unit":"kg/year","value":"31.7772"},"path":"/home/energy/quantity","profileItems":[{"amount":{"unit":"kg/year","value":31.7772},"uid":"B3D15D776EB9","startDate":"2010-06-28T13:14:00-04:00","itemValues":[{"itemValueDefinition":{"perUnit":"year","uid":"67B7476423C0","unit":"kWh","name":"Current Reading","fromData":false,"path":"currentReading","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"048EE4994F5B","startDate":"2010-06-28T13:14:00-04:00","unit":"kWh","name":"Current Reading","value":"0","path":"currentReading","displayPath":"currentReading","displayName":"Current Reading"},{"itemValueDefinition":{"perUnit":"year","uid":"068A0D6D03F7","unit":"kWh","name":"Energy Consumption","fromData":false,"path":"energyConsumption","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"month","uid":"2E52C3842819","startDate":"2010-06-28T13:14:00-04:00","unit":"kWh","name":"Energy Consumption","value":"13","path":"energyConsumption","displayPath":"energyConsumption","displayName":"Energy Consumption"},{"itemValueDefinition":{"uid":"1740E500BDAB","choices":"true=true,false=false","name":"Includes Heating","fromData":false,"path":"includesHeating","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"","uid":"98D6B86F928E","startDate":"2010-06-28T13:14:00-04:00","unit":"","name":"Includes Heating","value":"false","path":"includesHeating","displayPath":"includesHeating","displayName":"Includes Heating"},{"itemValueDefinition":{"uid":"527AADFB3B65","name":"Season","fromData":false,"path":"season","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"","uid":"142422F25D4E","startDate":"2010-06-28T13:14:00-04:00","unit":"","name":"Season","value":"","path":"season","displayPath":"season","displayName":"Season"},{"itemValueDefinition":{"uid":"63005554AE8A","name":"Green tariff","fromData":false,"path":"greenTariff","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"","uid":"3BBD254BA9BA","startDate":"2010-06-28T13:14:00-04:00","unit":"","name":"Green tariff","value":"","path":"greenTariff","displayPath":"greenTariff","displayName":"Green tariff"},{"itemValueDefinition":{"uid":"E0EFED6FD7E6","name":"Payment frequency","fromData":false,"path":"paymentFrequency","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"","uid":"4E57D4DEFC2A","startDate":"2010-06-28T13:14:00-04:00","unit":"","name":"Payment frequency","value":"","path":"paymentFrequency","displayPath":"paymentFrequency","displayName":"Payment frequency"},{"itemValueDefinition":{"perUnit":"year","uid":"CF12B3EBAD02","unit":"kg","name":"Mass Per Time","fromData":false,"path":"massPerTime","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"F0AE74C87EEE","startDate":"2010-06-28T13:14:00-04:00","unit":"kg","name":"Mass Per Time","value":"0","path":"massPerTime","displayPath":"massPerTime","displayName":"Mass Per Time"},{"itemValueDefinition":{"perUnit":"year","uid":"40AB7E90980C","unit":"kWh","name":"Last Reading","fromData":false,"path":"lastReading","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"99B9FDA5D1A8","startDate":"2010-06-28T13:14:00-04:00","unit":"kWh","name":"Last Reading","value":"0","path":"lastReading","displayPath":"lastReading","displayName":"Last Reading"},{"itemValueDefinition":{"perUnit":"year","uid":"177D4642A07A","name":"Number of deliveries","fromData":false,"path":"deliveries","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"EE0151C2C22C","startDate":"2010-06-28T13:14:00-04:00","unit":"","name":"Number of deliveries","value":"","path":"deliveries","displayPath":"deliveries","displayName":"Number of deliveries"},{"itemValueDefinition":{"perUnit":"year","uid":"324EC808AC30","unit":"L","name":"Volume Per Time","fromData":false,"path":"volumePerTime","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"35B94788B050","startDate":"2010-06-28T13:14:00-04:00","unit":"L","name":"Volume Per Time","value":"0","path":"volumePerTime","displayPath":"volumePerTime","displayName":"Volume Per Time"}],"amounts":{"amount":[{"perUnit":"year","unit":"kg","default":"true","value":31.7772,"type":"CO2"}]},"created":"2010-06-28T17:14:18Z","name":"gas","endDate":"","dataItem":{"uid":"66056991EE23","Label":"gas"},"modified":"2010-06-28T17:40:35Z"}],"profile":{"uid":"B6FB1C01BAA7"}}'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/447C40EB29FB/home/energy/quantity")
    @cat.total_amount.should be_within(1.0e-09).of(31.7772)
    @cat.total_amount_unit.should == "kg/year"
    @cat.items.size.should be(1)
    @cat.items[0][:uid].should == "B3D15D776EB9"
    @cat.items[0][:name].should == "gas"
    @cat.items[0][:path].should == "B3D15D776EB9"
    @cat.items[0][:dataItemLabel].should == "gas"
    @cat.items[0][:dataItemUid].should == "66056991EE23"
    @cat.items[0][:startDate].should == DateTime.new(2010, 6, 28, 17, 14)
    @cat.items[0][:endDate].should be_nil
    @cat.items[0][:amount].should be_within(1.0e-09).of(31.7772)
    @cat.items[0][:amount_unit].should == "kg/year"
    @cat.items[0][:values].size.should be(10)
    @cat.items[0][:values][:energyConsumption][:value].should == "13"
    @cat.items[0][:values][:energyConsumption][:unit].should == "kWh"
    @cat.items[0][:values][:energyConsumption][:per_unit].should == "month"
    @cat.items[0][:values][:massPerTime][:value].should == "0"
    @cat.items[0][:values][:volumePerTime][:value].should == "0"
    @cat.pager.should_not be_nil
  end
  
  it "should parse multiple return values" do
    connection = flexmock "connection"
    connection.should_receive(:version).and_return(2.0)
    connection.should_receive(:get).with("/profiles/F8C2D1052BF7/home/energy/quantity", {}).and_return(flexmock(:body => '{"apiVersion":"2.0","pager":{"to":1,"lastPage":1,"nextPage":-1,"items":1,"start":0,"itemsFound":1,"requestedPage":1,"currentPage":1,"from":1,"itemsPerPage":10,"previousPage":-1},"profileCategories":[],"dataCategory":{"uid":"A92693A99BAD","dataCategory":{"uid":"30BA55A0C472","deprecated":false,"name":"Energy","path":"energy"},"deprecated":false,"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10},"created":"2007-07-27 08:30:44.0","name":"Quantity","path":"quantity","itemDefinition":{"uid":"212C818D8F16","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","name":"Energy Quantity","drillDown":"type","modified":"2007-07-27 08:30:44.0"},"modified":"2007-07-27 08:30:44.0"},"environment":{"uid":"5F5887BCF726","itemsPerFeed":10,"created":"2007-07-27 08:30:44.0","description":"","name":"AMEE","owner":"","path":"","itemsPerPage":10,"modified":"2007-07-27 08:30:44.0"},"totalAmount":{"unit":"kg/year","value":"31.7772"},"path":"/home/energy/quantity","profileItems":[{"amount":{"unit":"kg/year","value":31.7772},"uid":"3BCDB0BB2B96","startDate":"2010-07-16T10:44:00-04:00","itemValues":[{"itemValueDefinition":{"perUnit":"year","uid":"67B7476423C0","unit":"kWh","name":"Current Reading","fromData":false,"path":"currentReading","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"06F553CED9F7","startDate":"2010-07-16T10:44:00-04:00","unit":"kWh","name":"Current Reading","value":"0","path":"currentReading","displayPath":"currentReading","displayName":"Current Reading"},{"itemValueDefinition":{"perUnit":"year","uid":"068A0D6D03F7","unit":"kWh","name":"Energy Consumption","fromData":false,"path":"energyConsumption","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"month","uid":"4CF7691084DB","startDate":"2010-07-16T10:44:00-04:00","unit":"kWh","name":"Energy Consumption","value":"13","path":"energyConsumption","displayPath":"energyConsumption","displayName":"Energy Consumption"},{"itemValueDefinition":{"uid":"1740E500BDAB","choices":"true=true,false=false","name":"Includes Heating","fromData":false,"path":"includesHeating","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"","uid":"1CA0D40208F0","startDate":"2010-07-16T10:44:00-04:00","unit":"","name":"Includes Heating","value":"false","path":"includesHeating","displayPath":"includesHeating","displayName":"Includes Heating"},{"itemValueDefinition":{"uid":"527AADFB3B65","name":"Season","fromData":false,"path":"season","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"","uid":"1ACEB4784A42","startDate":"2010-07-16T10:44:00-04:00","unit":"","name":"Season","value":"","path":"season","displayPath":"season","displayName":"Season"},{"itemValueDefinition":{"uid":"63005554AE8A","name":"Green tariff","fromData":false,"path":"greenTariff","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"","uid":"036262B5D69D","startDate":"2010-07-16T10:44:00-04:00","unit":"","name":"Green tariff","value":"","path":"greenTariff","displayPath":"greenTariff","displayName":"Green tariff"},{"itemValueDefinition":{"uid":"E0EFED6FD7E6","name":"Payment frequency","fromData":false,"path":"paymentFrequency","fromProfile":true,"valueDefinition":{"uid":"CCEB59CACE1B","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"text","valueType":"TEXT","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"","uid":"A568643CD1D7","startDate":"2010-07-16T10:44:00-04:00","unit":"","name":"Payment frequency","value":"","path":"paymentFrequency","displayPath":"paymentFrequency","displayName":"Payment frequency"},{"itemValueDefinition":{"perUnit":"year","uid":"CF12B3EBAD02","unit":"kg","name":"Mass Per Time","fromData":false,"path":"massPerTime","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"990F69A6BD48","startDate":"2010-07-16T10:44:00-04:00","unit":"kg","name":"Mass Per Time","value":"0","path":"massPerTime","displayPath":"massPerTime","displayName":"Mass Per Time"},{"itemValueDefinition":{"perUnit":"year","uid":"40AB7E90980C","unit":"kWh","name":"Last Reading","fromData":false,"path":"lastReading","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"A5BB73E6CBD2","startDate":"2010-07-16T10:44:00-04:00","unit":"kWh","name":"Last Reading","value":"0","path":"lastReading","displayPath":"lastReading","displayName":"Last Reading"},{"itemValueDefinition":{"perUnit":"year","uid":"324EC808AC30","unit":"L","name":"Volume Per Time","fromData":false,"path":"volumePerTime","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"DA93374B62C2","startDate":"2010-07-16T10:44:00-04:00","unit":"L","name":"Volume Per Time","value":"0","path":"volumePerTime","displayPath":"volumePerTime","displayName":"Volume Per Time"},{"itemValueDefinition":{"perUnit":"year","uid":"177D4642A07A","name":"Number of deliveries","fromData":false,"path":"deliveries","fromProfile":true,"valueDefinition":{"uid":"45433E48B39F","environment":{"uid":"5F5887BCF726"},"created":"2007-07-27 08:30:44.0","description":"","name":"amount","valueType":"DECIMAL","modified":"2007-07-27 08:30:44.0"},"drillDown":false},"perUnit":"year","uid":"FA09F1FF043D","startDate":"2010-07-16T10:44:00-04:00","unit":"","name":"Number of deliveries","value":"","path":"deliveries","displayPath":"deliveries","displayName":"Number of deliveries"}],"amounts":{"amount":[{"perUnit":"year","unit":"kg","default":"true","value":31.7772,"type":"CO2"},{"type":"CH4","unit":"kg","value":4.2}],"note":[{"type" : "comment","value" : "This is a text node"},{"type" : "comment","value" : "This is another text node"}]},"created":"2010-07-16T14:44:43Z","name":"gas","endDate":"","dataItem":{"uid":"66056991EE23","Label":"gas"},"modified":"2010-07-16T14:45:03Z"}],"profile":{"uid":"F8C2D1052BF7"}}'))
    @cat = AMEE::Profile::Category.get(connection, "/profiles/F8C2D1052BF7/home/energy/quantity")
    @cat.total_amount.should be_within(0.0001).of(31.7772)
    @cat.total_amount_unit.should == 'kg/year'
    item = @cat.items[0]
    item[:amounts].size.should be(2)
    item[:amounts][0][:type].should == "CO2"
    item[:amounts][0][:value].should be_within(0.0001).of(31.7772)
    item[:amounts][0][:unit].should == 'kg'
    item[:amounts][0][:per_unit].should == 'year'
    item[:amounts][0][:default].should be_true
    item[:amounts][1][:type].should == "CH4"
    item[:amounts][1][:value].should be_within(0.01).of(4.2)
    item[:amounts][1][:unit].should == 'kg'
    item[:amounts][1][:per_unit].should be_nil
    item[:notes].size.should be(2)
    item[:notes][0][:type].should == 'comment'
    item[:notes][0][:value].should == 'This is a text node'
    item[:notes][1][:type].should == 'comment'
    item[:notes][1][:value].should == 'This is another text node'
  end

#
#  it "should fail gracefully with incorrect data" do
#    connection = flexmock "connection"
#    connection.should_receive(:get).with("/profiles/E54C5525AA3E", {}).and_return('{}'))
#    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData)
#  end

#  it "parses recursive GET requests" do
#    connection = flexmock "connection"
#    connection.should_receive(:version).and_return(2.0)
#    connection.should_receive(:get).with("/profiles/BE22C1732952/transport/car", {:recurse => true}).and_return('{"totalAmountPerMonth":"0","dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"profileDate":"200901","path":"/transport/car","profile":{"uid":"BE22C1732952"},"children":{"pager":{},"dataCategories":[{"dataCategory":{"modified":"2008-04-21 16:42:10.0","created":"2008-04-21 16:42:10.0","itemDefinition":{"uid":"C6BC60C55678"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"883ADD27228F","environment":{"uid":"5F5887BCF726"},"path":"bands","name":"Bands"},"path":"/transport/car/bands"},{"totalAmountPerMonth":0.265,"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","itemDefinition":{"uid":"123C4A18B5D6"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"87E55DA88017","environment":{"uid":"5F5887BCF726"},"path":"generic","name":"Generic"},"path":"/transport/car/generic","children":{"dataCategories":[{"dataCategory":{"modified":"2008-09-23 12:18:03.0","created":"2008-09-23 12:18:03.0","itemDefinition":{"uid":"E6D0BB09578A"},"dataCategory":{"uid":"87E55DA88017","path":"generic","name":"Generic"},"uid":"417DD367E9AA","environment":{"uid":"5F5887BCF726"},"path":"electric","name":"Electric"},"path":"/transport/car/generic/electric"}],"profileItems":{"rows":[{"created":"2009-01-05 13:58:52.0","ecoDriving":"false","tyresUnderinflated":"false","dataItemLabel":"diesel, large","kmPerLitre":"0","distanceKmPerMonth":"1","end":"false","uid":"8450D6D97D2D","modified":"2009-01-05 13:59:05.0","airconFull":"false","dataItemUid":"4F6CBCEE95F7","validFrom":"20090101","amountPerMonth":"0.265","kmPerLitreOwn":"0","country":"","label":"ProfileItem","occupants":"-1","airconTypical":"true","path":"8450D6D97D2D","name":"","regularlyServiced":"true"}],"label":"ProfileItems"}}},{"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","itemDefinition":{"uid":"07EBA32512DF"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"95E76249584D","environment":{"uid":"5F5887BCF726"},"path":"specific","name":"Specific"},"path":"/transport/car/specific"}],"profileItems":{}}}'))
#    cat = AMEE::Profile::Category.get(connection, "/profiles/BE22C1732952/transport/car", :recurse => true)
#    cat.items.size.should == 0
#    cat.children.size.should == 3
#    cat.children[1][:name].should == "Generic"
#    cat.children[1][:path].should == "generic"
#    cat.children[1][:uid].should == "87E55DA88017"
#    cat.children[1][:totalAmountPerMonth].should == 0.265
#    cat.children[1][:children].size.should == 1
#    cat.children[1][:children][0][:name].should == "Electric"
#    cat.children[1][:children][0][:path].should == "electric"
#    cat.children[1][:children][0][:uid].should == "417DD367E9AA"
#    cat.children[1][:items].size.should == 1
#    cat.children[1][:items][0][:amountPerMonth].should == 0.265
#    cat.children[1][:items][0][:dataItemLabel].should == "diesel, large"
#    cat.children[1][:items][0][:dataItemUid].should == "4F6CBCEE95F7"
#    cat.children[1][:items][0][:values][:airconTypical].should == "true"
#    cat.children[1][:items][0][:uid].should == "8450D6D97D2D"
#  end

end

describe AMEE::Profile::Category, "with an authenticated connection" do

  it "allows direct access to ProfileItems" do

  end

  it "should fail gracefully on other GET errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E", {}).and_raise("unidentified error")
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData)
  end

end
