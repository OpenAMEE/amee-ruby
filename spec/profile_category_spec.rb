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
  
describe AMEE::Data::Category, "with an authenticated XML connection" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><Children><ProfileCategories><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><DataCategory uid="30BA55A0C472"><Name>Energy</Name><Path>energy</Path></DataCategory><DataCategory uid="A46ECFA19333"><Name>Heating</Name><Path>heating</Path></DataCategory><DataCategory uid="150266DD4434"><Name>Lighting</Name><Path>lighting</Path></DataCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>')
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
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="BBA3AC3E795E"><Name>Home</Name><Path>home</Path></DataCategory><Children><ProfileCategories><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><DataCategory uid="30BA55A0C472"><Name>Energy</Name><Path>energy</Path></DataCategory><DataCategory uid="A46ECFA19333"><Name>Heating</Name><Path>heating</Path></DataCategory><DataCategory uid="150266DD4434"><Name>Lighting</Name><Path>lighting</Path></DataCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>')
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/appliances").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home/appliances</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="427DFCC65E52"><Name>Appliances</Name><Path>appliances</Path></DataCategory><Children><ProfileCategories><DataCategory uid="3FE23FDC8CEA"><Name>Computers</Name><Path>computers</Path></DataCategory><DataCategory uid="54C8A44254AA"><Name>Cooking</Name><Path>cooking</Path></DataCategory><DataCategory uid="75AD9B83B7BF"><Name>Entertainment</Name><Path>entertainment</Path></DataCategory><DataCategory uid="4BD595E1873A"><Name>Kitchen</Name><Path>kitchen</Path></DataCategory><DataCategory uid="700D0771870A"><Name>Televisions</Name><Path>televisions</Path></DataCategory></ProfileCategories></Children></ProfileCategoryResource></Resources>')
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home")
    @child = @cat.child('appliances')
    @child.path.should == "/home/appliances"
    @child.full_path.should == "/profiles/E54C5525AA3E/home/appliances"
    @child.children.size.should be(5)
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/energy/quantity").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfileCategoryResource><Path>/home/energy/quantity</Path><ProfileDate>200809</ProfileDate><Profile uid="E54C5525AA3E"/><DataCategory uid="A92693A99BAD"><Name>Quantity</Name><Path>quantity</Path></DataCategory><Children><ProfileCategories/><ProfileItems><ProfileItem created="2008-09-03 11:37:35.0" modified="2008-09-03 11:38:12.0" uid="FB07247AD937"><validFrom>20080902</validFrom><end>false</end><kWhPerMonth>12</kWhPerMonth><amountPerMonth>2.472</amountPerMonth><dataItemUid>66056991EE23</dataItemUid><kgPerMonth>0</kgPerMonth><path>FB07247AD937</path><litresPerMonth>0</litresPerMonth><name>gas</name><dataItemLabel>gas</dataItemLabel></ProfileItem><ProfileItem created="2008-09-03 11:40:44.0" modified="2008-09-03 11:41:54.0" uid="D9CBCDED44C5"><validFrom>20080901</validFrom><end>false</end><kWhPerMonth>500</kWhPerMonth><amountPerMonth>103.000</amountPerMonth><dataItemUid>66056991EE23</dataItemUid><kgPerMonth>0</kgPerMonth><path>D9CBCDED44C5</path><litresPerMonth>0</litresPerMonth><name>gas2</name><dataItemLabel>gas</dataItemLabel></ProfileItem></ProfileItems><Pager><Start>0</Start><From>1</From><To>2</To><Items>2</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>2</ItemsFound></Pager></Children><TotalAmountPerMonth>105.472</TotalAmountPerMonth></ProfileCategoryResource></Resources>')
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
    connection.should_receive(:get).with("/profiles/E54C5525AA3E").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>')
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData, "Couldn't load ProfileCategory from XML data. Check that your URL is correct.")
  end

end

describe AMEE::Data::Category, "with an authenticated JSON connection" do

  it "should load Profile Category" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home").and_return('{"totalAmountPerMonth":"0","dataCategory":{"uid":"BBA3AC3E795E","path":"home","name":"Home"},"profileDate":"200809","path":"/home","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{},"dataCategories":[{"uid":"427DFCC65E52","path":"appliances","name":"Appliances"},{"uid":"30BA55A0C472","path":"energy","name":"Energy"},{"uid":"A46ECFA19333","path":"heating","name":"Heating"},{"uid":"150266DD4434","path":"lighting","name":"Lighting"}],"profileItems":{}}}')
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
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home").and_return('{"totalAmountPerMonth":"0","dataCategory":{"uid":"BBA3AC3E795E","path":"home","name":"Home"},"profileDate":"200809","path":"/home","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{},"dataCategories":[{"uid":"427DFCC65E52","path":"appliances","name":"Appliances"},{"uid":"30BA55A0C472","path":"energy","name":"Energy"},{"uid":"A46ECFA19333","path":"heating","name":"Heating"},{"uid":"150266DD4434","path":"lighting","name":"Lighting"}],"profileItems":{}}}')
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/appliances").and_return('{"totalAmountPerMonth":"0","dataCategory":{"uid":"427DFCC65E52","path":"appliances","name":"Appliances"},"profileDate":"200809","path":"/home/appliances","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{},"dataCategories":[{"uid":"3FE23FDC8CEA","path":"computers","name":"Computers"},{"uid":"54C8A44254AA","path":"cooking","name":"Cooking"},{"uid":"75AD9B83B7BF","path":"entertainment","name":"Entertainment"},{"uid":"4BD595E1873A","path":"kitchen","name":"Kitchen"},{"uid":"700D0771870A","path":"televisions","name":"Televisions"}],"profileItems":{}}}')
    @cat = AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E/home")
    @child = @cat.child('appliances')
    @child.path.should == "/home/appliances"
    @child.full_path.should == "/profiles/E54C5525AA3E/home/appliances"
    @child.children.size.should be(5)
  end

  it "should parse data items" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E/home/energy/quantity").and_return('{"totalAmountPerMonth":105.472,"dataCategory":{"uid":"A92693A99BAD","path":"quantity","name":"Quantity"},"profileDate":"200809","path":"/home/energy/quantity","profile":{"uid":"E54C5525AA3E"},"children":{"pager":{"to":2,"lastPage":1,"start":0,"nextPage":-1,"items":2,"itemsPerPage":10,"from":1,"previousPage":-1,"requestedPage":1,"currentPage":1,"itemsFound":2},"dataCategories":[],"profileItems":{"rows":[{"created":"2008-09-03 11:37:35.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"FB07247AD937","modified":"2008-09-03 11:38:12.0","dataItemUid":"66056991EE23","validFrom":"20080902","amountPerMonth":"2.472","label":"ProfileItem","litresPerMonth":"0","path":"FB07247AD937","kWhPerMonth":"12","name":"gas"},{"created":"2008-09-03 11:40:44.0","kgPerMonth":"0","dataItemLabel":"gas","end":"false","uid":"D9CBCDED44C5","modified":"2008-09-03 11:41:54.0","dataItemUid":"66056991EE23","validFrom":"20080901","amountPerMonth":"103.000","label":"ProfileItem","litresPerMonth":"0","path":"D9CBCDED44C5","kWhPerMonth":"500","name":"gas2"}],"label":"ProfileItems"}}}')
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
    connection.should_receive(:get).with("/profiles/E54C5525AA3E").and_return('{}')
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData, "Couldn't load ProfileCategory from JSON data. Check that your URL is correct.")
  end

end

describe AMEE::Profile::Category, "with an authenticated connection" do

  it "should fail gracefully on other GET errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles/E54C5525AA3E").and_raise("unidentified error")
    lambda{AMEE::Profile::Category.get(connection, "/profiles/E54C5525AA3E")}.should raise_error(AMEE::BadData, "Couldn't load ProfileCategory. Check that your URL is correct.")
  end

end
