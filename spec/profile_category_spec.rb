require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Profile::Category do
  
  before(:each) do
    @cat = AMEE::Profile::Category.new
  end
  
  it "should have common AMEE object properties" do
    @cat.is_a?(AMEE::Profile::Object).should be_true
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
  
describe AMEE::Profile::Category, "with an authenticated XML connection" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><Children><ProfileCategories><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><DataCategory uid="30BA55A0C472"><Name>Energy</Name><Path>energy</Path></DataCategory><DataCategory uid="A46ECFA19333"><Name>Heating</Name><Path>heating</Path></DataCategory><DataCategory uid="150266DD4434"><Name>Lighting</Name><Path>lighting</Path></DataCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>')
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
  end

  it "should provide access to child objects" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><Children><ProfileCategories><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><DataCategory uid="30BA55A0C472"><Name>Energy</Name><Path>energy</Path></DataCategory><DataCategory uid="A46ECFA19333"><Name>Heating</Name><Path>heating</Path></DataCategory><DataCategory uid="150266DD4434"><Name>Lighting</Name><Path>lighting</Path></DataCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>')
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/appliances", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home/appliances</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><Children><ProfileCategories><DataCategory uid="3FE23FDC8CEA"><Name>Computers</Name><Path>computers</Path></DataCategory><DataCategory uid="54C8A44254AA"><Name>Cooking</Name><Path>cooking</Path></DataCategory><DataCategory uid="75AD9B83B7BF"><Name>Entertainment</Name><Path>entertainment</Path></DataCategory><DataCategory uid="4BD595E1873A"><Name>Kitchen</Name><Path>kitchen</Path></DataCategory><DataCategory uid="700D0771870A"><Name>Televisions</Name><Path>televisions</Path></DataCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>')
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home")
    @child = @cat.child('appliances')
    @child.path.should == "/home/appliances"
    @child.full_path.should == "/profiles/E54C5525AA3E/home/appliances"
    @child.children.size.should be(5)
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/energy/quantity", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home/energy/quantity</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="A92693A99BAD"><Name>Quantity</Name><Path>quantity</Path></DataCategory><Children><ProfileCategories/><ProfileItems><ProfileItem created="2008-09-03 11:37:35.0" modified="2008-09-03 11:38:12.0" uid="FB07247AD937"><validFrom>20080902</validFrom><end>false</end><kWhPerMonth>12</kWhPerMonth><amountPerMonth>2.472</amountPerMonth><dataItemUid>66056991EE23</dataItemUid><kgPerMonth>0</kgPerMonth><path>FB07247AD937</path><litresPerMonth>0</litresPerMonth><name>gas</name><dataItemLabel>gas</dataItemLabel></ProfileItem><ProfileItem created="2008-09-03 11:40:44.0" modified="2008-09-03 11:41:54.0" uid="D9CBCDED44C5"><validFrom>20080901</validFrom><end>false</end><kWhPerMonth>500</kWhPerMonth><amountPerMonth>103.000</amountPerMonth><dataItemUid>66056991EE23</dataItemUid><kgPerMonth>0</kgPerMonth><path>D9CBCDED44C5</path><litresPerMonth>0</litresPerMonth><name>gas2</name><dataItemLabel>gas</dataItemLabel></ProfileItem></ProfileItems><Pager><Start>0</Start><From>1</From><To>2</To><Items>2</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>2</ItemsFound></Pager></Children><TotalAmountPerMonth>105.472</TotalAmountPerMonth></ProfileCategoryResource></Resources>')
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home/energy/quantity")
    @cat.total_amount_per_month.should be_close(105.472, 1e-9)
    @cat.items.size.should be(2)
    @cat.items[0][:uid].should == "FB07247AD937"
    @cat.items[0][:name].should == "gas"
    @cat.items[0][:path].should == "FB07247AD937"
    @cat.items[0][:dataItemLabel].should == "gas"
    @cat.items[0][:dataItemUid].should == "66056991EE23"
    @cat.items[0][:validFrom].should == DateTime.new(2008, 9, 2)
    @cat.items[0][:end].should == false
    @cat.items[0][:amountPerMonth].should be_close(2.472, 1e-9)
    @cat.items[0][:values].size.should be(3)
    @cat.items[0][:values][:kWhPerMonth].should == "12"
    @cat.items[0][:values][:kgPerMonth].should == "0"
    @cat.items[0][:values][:litresPerMonth].should == "0"
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>')
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData, "Couldn't load ProfileCategory from XML data. Check that your URL is correct.")
  end

  it "parses recursive GET requests" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/BE22C1732952/transport/car", {:recurse=>true, :itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/transport/car</Path><ProfileDate>200901</ProfileDate><Profile uid="BE22C1732952"/><DataCategory uid="1D95119FB149"><Name>Car</Name><Path>car</Path></DataCategory><Children><ProfileCategories><ProfileCategory><Path>/transport/car/bands</Path><DataCategory uid="883ADD27228F"><Name>Bands</Name><Path>bands</Path></DataCategory></ProfileCategory><ProfileCategory><Path>/transport/car/generic</Path><DataCategory uid="87E55DA88017"><Name>Generic</Name><Path>generic</Path></DataCategory><Children><ProfileCategories><ProfileCategory><Path>/transport/car/generic/electric</Path><DataCategory uid="417DD367E9AA"><Name>Electric</Name><Path>electric</Path></DataCategory></ProfileCategory></ProfileCategories><ProfileItems><ProfileItem created="2009-01-05 13:58:52.0" modified="2009-01-05 13:59:05.0" uid="8450D6D97D2D"><distanceKmPerMonth>1</distanceKmPerMonth><validFrom>20090101</validFrom><end>false</end><airconTypical>true</airconTypical><ecoDriving>false</ecoDriving><airconFull>false</airconFull><kmPerLitreOwn>0</kmPerLitreOwn><country/><tyresUnderinflated>false</tyresUnderinflated><amountPerMonth>0.265</amountPerMonth><occupants>-1</occupants><kmPerLitre>0</kmPerLitre><dataItemUid>4F6CBCEE95F7</dataItemUid><regularlyServiced>true</regularlyServiced><path>8450D6D97D2D</path><name/><dataItemLabel>diesel, large</dataItemLabel></ProfileItem></ProfileItems></Children><TotalAmountPerMonth>0.265</TotalAmountPerMonth></ProfileCategory><ProfileCategory><Path>/transport/car/specific</Path><DataCategory uid="95E76249584D"><Name>Specific</Name><Path>specific</Path></DataCategory></ProfileCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>')
    cat = AMEE::Profile::Category.get(connection, "/profiles/BE22C1732952/transport/car", Date.today, 10, true)
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
  end

end

describe AMEE::Profile::Category, "with an authenticated JSON connection" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('{"totalAmountPerMonth":"0","dataCategory":{"uid":"BBA3AC3E795E","path":"home","name":"Home"},"profileDate":"200809","path":"/home","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{},"dataCategories":[{"uid":"427DFCC65E52","path":"appliances","name":"Appliances"},{"uid":"30BA55A0C472","path":"energy","name":"Energy"},{"uid":"A46ECFA19333","path":"heating","name":"Heating"},{"uid":"150266DD4434","path":"lighting","name":"Lighting"}],"profileItems":{}}}')
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
  end

  it "should provide access to child objects" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('{"totalAmountPerMonth":"0","dataCategory":{"uid":"BBA3AC3E795E","path":"home","name":"Home"},"profileDate":"200809","path":"/home","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{},"dataCategories":[{"uid":"427DFCC65E52","path":"appliances","name":"Appliances"},{"uid":"30BA55A0C472","path":"energy","name":"Energy"},{"uid":"A46ECFA19333","path":"heating","name":"Heating"},{"uid":"150266DD4434","path":"lighting","name":"Lighting"}],"profileItems":{}}}')
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/appliances", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('{"totalAmountPerMonth":"0","dataCategory":{"uid":"427DFCC65E52","path":"appliances","name":"Appliances"},"profileDate":"200809","path":"/home/appliances","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{},"dataCategories":[{"uid":"3FE23FDC8CEA","path":"computers","name":"Computers"},{"uid":"54C8A44254AA","path":"cooking","name":"Cooking"},{"uid":"75AD9B83B7BF","path":"entertainment","name":"Entertainment"},{"uid":"4BD595E1873A","path":"kitchen","name":"Kitchen"},{"uid":"700D0771870A","path":"televisions","name":"Televisions"}],"profileItems":{}}}')
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home")
    @child = @cat.child('appliances')
    @child.path.should == "/home/appliances"
    @child.full_path.should == "/profiles/E54C5525AA3E/home/appliances"
    @child.children.size.should be(5)
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/energy/quantity", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('{"totalAmountPerMonth":105.472,"dataCategory":{"uid":"A92693A99BAD","path":"quantity","name":"Quantity"},"profileDate":"200809","path":"/home/energy/quantity","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{"to":2,"lastPage":1,"start":0,"nextPage":-1,"items":2,"itemsPerPage":10,"from":1,"previousPage":-1,"requestedPage":1,"currentPage":1,"itemsFound":2},"dataCategories":[],"profileItems":{"rows":[{"created":"2008-09-03 11:37:35.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"FB07247AD937","modified":"2008-09-03 11:38:12.0","dataItemUid":"66056991EE23","validFrom":"20080902","amountPerMonth":"2.472","label":"ProfileItem","litresPerMonth":"0","path":"FB07247AD937","kWhPerMonth":"12","name":"gas"},{"created":"2008-09-03 11:40:44.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"D9CBCDED44C5","modified":"2008-09-03 11:41:54.0","dataItemUid":"66056991EE23","validFrom":"20080901","amountPerMonth":"103.000","label":"ProfileItem","litresPerMonth":"0","path":"D9CBCDED44C5","kWhPerMonth":"500","name":"gas2"}],"label":"ProfileItems"}}}')
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home/energy/quantity")
    @cat.total_amount_per_month.should be_close(105.472, 1e-9)
    @cat.items.size.should be(2)
    @cat.items[0][:uid].should == "FB07247AD937"
    @cat.items[0][:name].should == "gas"
    @cat.items[0][:path].should == "FB07247AD937"
    @cat.items[0][:dataItemLabel].should == "gas"
    @cat.items[0][:dataItemUid].should == "66056991EE23"
    @cat.items[0][:validFrom].should == DateTime.new(2008, 9, 2)
    @cat.items[0][:end].should == false
    @cat.items[0][:amountPerMonth].should be_close(2.472, 1e-9)
    @cat.items[0][:values].size.should be(3)
    @cat.items[0][:values][:kWhPerMonth].should == "12"
    @cat.items[0][:values][:kgPerMonth].should == "0"
    @cat.items[0][:values][:litresPerMonth].should == "0"
  end

  it "should fail gracefully with incorrect data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('{}')
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData, "Couldn't load ProfileCategory from JSON data. Check that your URL is correct.")
  end

  it "parses recursive GET requests" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/BE22C1732952/transport/car", {:recurse=>true, :itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_return('{"totalAmountPerMonth":"0","dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"profileDate":"200901","path":"/transport/car","profile":{"uid":"BE22C1732952"},"children":{"pager":{},"dataCategories":[{"dataCategory":{"modified":"2008-04-21 16:42:10.0","created":"2008-04-21 16:42:10.0","itemDefinition":{"uid":"C6BC60C55678"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"883ADD27228F","environment":{"uid":"5F5887BCF726"},"path":"bands","name":"Bands"},"path":"/transport/car/bands"},{"totalAmountPerMonth":0.265,"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","itemDefinition":{"uid":"123C4A18B5D6"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"87E55DA88017","environment":{"uid":"5F5887BCF726"},"path":"generic","name":"Generic"},"path":"/transport/car/generic","children":{"dataCategories":[{"dataCategory":{"modified":"2008-09-23 12:18:03.0","created":"2008-09-23 12:18:03.0","itemDefinition":{"uid":"E6D0BB09578A"},"dataCategory":{"uid":"87E55DA88017","path":"generic","name":"Generic"},"uid":"417DD367E9AA","environment":{"uid":"5F5887BCF726"},"path":"electric","name":"Electric"},"path":"/transport/car/generic/electric"}],"profileItems":{"rows":[{"created":"2009-01-05 13:58:52.0","ecoDriving":"false","tyresUnderinflated":"false","dataItemLabel":"diesel, large","kmPerLitre":"0","distanceKmPerMonth":"1","end":"false","uid":"8450D6D97D2D","modified":"2009-01-05 13:59:05.0","airconFull":"false","dataItemUid":"4F6CBCEE95F7","validFrom":"20090101","amountPerMonth":"0.265","kmPerLitreOwn":"0","country":"","label":"ProfileItem","occupants":"-1","airconTypical":"true","path":"8450D6D97D2D","name":"","regularlyServiced":"true"}],"label":"ProfileItems"}}},{"dataCategory":{"modified":"2007-07-27 09:30:44.0","created":"2007-07-27 09:30:44.0","itemDefinition":{"uid":"07EBA32512DF"},"dataCategory":{"uid":"1D95119FB149","path":"car","name":"Car"},"uid":"95E76249584D","environment":{"uid":"5F5887BCF726"},"path":"specific","name":"Specific"},"path":"/transport/car/specific"}],"profileItems":{}}}')
    cat = AMEE::Profile::Category.get(connection, "/profiles/BE22C1732952/transport/car", Date.today, 10, true)
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
  end

end

describe AMEE::Profile::Category, "with an authenticated connection" do

  it "allows direct access to ProfileItems" do
    
  end

  it "should fail gracefully on other GET errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E", {:itemsPerPage => 10, :profileDate=>Date.today.strftime("%Y%m")}).and_raise("unidentified error")
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData, "Couldn't load ProfileCategory. Check that your URL is correct.")
  end

end
