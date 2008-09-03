require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Profile::Profile do
  
  it "should have common AMEE object properties" do
    AMEE::Profile::Profile.new.is_a?(AMEE::Profile::Object).should be_true
  end
  
  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    profile = AMEE::Profile::Profile.new(:uid => uid)
    profile.uid.should == uid
  end

end

describe AMEE::Profile::Profile, "with an authenticated connection" do

  it "should provide access to list of profiles" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfilesResource><Profiles><Profile created="2008-07-24 10:45:08.0" modified="2008-07-24 10:45:08.0" uid="B59C2AA75C7F"><Path/><Name/><Environment uid="5F5887BCF726"/><Permission created="2008-07-24 10:45:08.0" modified="2008-07-24 10:45:08.0" uid="44406616CCAB"><Environment uid="5F5887BCF726"/><Name>amee</Name><Username>floppy</Username></Permission></Profile><Profile created="2008-07-22 13:10:59.0" modified="2008-07-22 13:10:59.0" uid="59D8E437FA70"><Path/><Name/><Environment uid="5F5887BCF726"/><Permission created="2008-07-22 13:10:59.0" modified="2008-07-22 13:10:59.0" uid="EFE285A403D0"><Environment uid="5F5887BCF726"/><Name>amee</Name><Username>floppy</Username></Permission></Profile></Profiles><Pager><Start>0</Start><From>1</From><To>2</To><Items>2</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>2</ItemsFound></Pager></ProfilesResource></Resources>')
    profiles = AMEE::Profile::Profile.list(connection)
    profiles.size.should be(2)
  end
  
  it "should fail gracefully with incorrect profile list data" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles").and_return('{}')
    lambda{AMEE::Profile::Profile.list(connection)}.should raise_error(AMEE::BadData, "Couldn't load Profile list.")
  end

  it "should parse JSON data correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles").and_return('{"pager":{"to":1,"lastPage":1,"start":0,"nextPage":-1,"items":1,"itemsPerPage":10,"from":1,"previousPage":-1,"requestedPage":1,"currentPage":1,"itemsFound":1},"profiles":[{"modified":"2008-07-24 10:50:23.0","created":"2008-07-24 10:49:23.0","uid":"A508956A847F","permission":{"modified":"2008-07-24 10:49:23.0","created":"2008-07-24 10:49:23.0","user":{"uid":"1A6307E2B531","username":"floppy"},"group":{"uid":"AC65FFA5F9D9","name":"amee"},"environmentUid":"5F5887BCF726","uid":"787915F05BBD"},"environment":{"uid":"5F5887BCF726"},"path":"A508956A847F","name":"A508956A847F"}]}')
    profile = AMEE::Profile::Profile.list(connection)[0]
    profile.uid.should == "A508956A847F"
    profile.name.should == "A508956A847F"
    profile.path.should == "/A508956A847F"
    profile.full_path.should == "/profiles/A508956A847F"
    profile.created.should == DateTime.new(2008,7,24,10,49,23)
    profile.modified.should == DateTime.new(2008,7,24,10,50,23)
  end
  
  it "should parse XML data correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfilesResource><Profiles><Profile created="2008-07-24 10:45:08.0" modified="2008-07-24 10:55:08.0" uid="B59C2AA75C7F"><Path/><Name/><Environment uid="5F5887BCF726"/><Permission created="2008-07-24 10:45:08.0" modified="2008-07-24 10:45:08.0" uid="44406616CCAB"><Environment uid="5F5887BCF726"/><Name>amee</Name><Username>floppy</Username></Permission></Profile><Profile created="2008-07-22 13:10:59.0" modified="2008-07-22 13:10:59.0" uid="59D8E437FA70"><Path/><Name/><Environment uid="5F5887BCF726"/><Permission created="2008-07-22 13:10:59.0" modified="2008-07-22 13:10:59.0" uid="EFE285A403D0"><Environment uid="5F5887BCF726"/><Name>amee</Name><Username>floppy</Username></Permission></Profile></Profiles><Pager><Start>0</Start><From>1</From><To>2</To><Items>2</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>2</ItemsFound></Pager></ProfilesResource></Resources>')
    profile = AMEE::Profile::Profile.list(connection)[0]
    profile.uid.should == "B59C2AA75C7F"
    profile.name.should == "B59C2AA75C7F"
    profile.path.should == "/B59C2AA75C7F"
    profile.full_path.should == "/profiles/B59C2AA75C7F"
    profile.created.should == DateTime.new(2008,7,24,10,45,8)
    profile.modified.should == DateTime.new(2008,7,24,10,55,8)
  end

  it "should be able to create new profiles (XML)" do
    connection = flexmock "connection"
    connection.should_receive(:post).with("/profiles", :profile => true).and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfilesResource><Profile created="Wed May 23 13:34:45 BST 2007" modified="Wed May 23 13:34:45 BST 2007" uid="04C3F8A10B30"><Path/><Name/><Site uid="C420F0C34227"/><Permission created="Wed May 23 13:34:45 BST 2007" modified="Wed May 23 13:34:45 BST 2007" uid="F06E9C383BFD"><Site uid="C420F0C34227"/><Name>Administrators</Name><Username>root</Username></Permission></Profile></ProfilesResource></Resources>')
    profile = AMEE::Profile::Profile.create(connection)
    profile.uid.should == "04C3F8A10B30"
    profile.name.should == "04C3F8A10B30"
    profile.path.should == "04C3F8A10B30"
    profile.created.should == DateTime.new(2007,5,23,12,34,45)
    profile.modified.should == DateTime.new(2007,5,23,12,34,45)
  end
  
  it "should be able to create new profiles (JSON)" do
    connection = flexmock "connection"
    connection.should_receive(:post).with("/profiles", :profile => true).and_return('{"profile":{"modified":"Wed May 23 13:36:19 BST 2007","created":"Wed May 23 13:36:19 BST 2007","site":{"uid":"C420F0C34227"},"uid":"F3A7EAE5C99B","permission":{"modified":"Wed May 23 13:36:19 BST 2007","created":"Wed May 23 13:36:19 BST 2007","user":{"uid":"7C41EA37BA4F","username":"root"},"group":{"uid":"3B71F24E93BC","name":"Administrators"},"siteUid":"C420F0C34227","uid":"CC153E13FB7E"},"path":"F3A7EAE5C99B","name":"F3A7EAE5C99B"}}')
    profile = AMEE::Profile::Profile.create(connection)
    profile.uid.should == "F3A7EAE5C99B"
    profile.name.should == "F3A7EAE5C99B"
    profile.path.should == "F3A7EAE5C99B"
    profile.created.should == DateTime.new(2007,5,23,12,36,19)
    profile.modified.should == DateTime.new(2007,5,23,12,36,19)
  end

  it "should fail gracefully if new profile creation fails" do
    connection = flexmock "connection"
    connection.should_receive(:post).with("/profiles", :profile => true).and_return('{}')
    lambda{AMEE::Profile::Profile.create(connection)}.should raise_error(AMEE::BadData, "Couldn't create Profile.")
  end

end
