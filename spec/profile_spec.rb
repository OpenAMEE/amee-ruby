require File.dirname(__FILE__) + '/spec_helper.rb'

describe AMEE::Profile do
  
  it "should have common AMEE object properties" do
    AMEE::Profile.new.is_a?(AMEE::Object).should be_true
  end
  
  it "should initialize AMEE::Object data on creation" do
    uid = 'ABCD1234'
    profile = AMEE::Profile.new(:uid => uid)
    profile.uid.should == uid
  end

end

describe AMEE::Profile, "with an authenticated connection" do

  it "should provide access to list of profiles" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfilesResource><Profiles><Profile created="2008-07-24 10:45:08.0" modified="2008-07-24 10:45:08.0" uid="B59C2AA75C7F"><Path/><Name/><Environment uid="5F5887BCF726"/><Permission created="2008-07-24 10:45:08.0" modified="2008-07-24 10:45:08.0" uid="44406616CCAB"><Environment uid="5F5887BCF726"/><Name>amee</Name><Username>floppy</Username></Permission></Profile><Profile created="2008-07-22 13:10:59.0" modified="2008-07-22 13:10:59.0" uid="59D8E437FA70"><Path/><Name/><Environment uid="5F5887BCF726"/><Permission created="2008-07-22 13:10:59.0" modified="2008-07-22 13:10:59.0" uid="EFE285A403D0"><Environment uid="5F5887BCF726"/><Name>amee</Name><Username>floppy</Username></Permission></Profile></Profiles><Pager><Start>0</Start><From>1</From><To>2</To><Items>2</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>2</ItemsFound></Pager></ProfilesResource></Resources>')
    profiles = AMEE::Profile.list(connection)
    profiles.size.should be(2)
  end
  
  it "should parse JSON data correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles").and_return('{"pager":{"to":1,"lastPage":1,"start":0,"nextPage":-1,"items":1,"itemsPerPage":10,"from":1,"previousPage":-1,"requestedPage":1,"currentPage":1,"itemsFound":1},"profiles":[{"modified":"2008-07-24 10:50:23.0","created":"2008-07-24 10:49:23.0","uid":"A508956A847F","permission":{"modified":"2008-07-24 10:49:23.0","created":"2008-07-24 10:49:23.0","user":{"uid":"1A6307E2B531","username":"floppy"},"group":{"uid":"AC65FFA5F9D9","name":"amee"},"environmentUid":"5F5887BCF726","uid":"787915F05BBD"},"environment":{"uid":"5F5887BCF726"},"path":"A508956A847F","name":"A508956A847F"}]}')
    profile = AMEE::Profile.list(connection)[0]
    profile.uid.should == "A508956A847F"
    profile.name.should == "A508956A847F"
    profile.path.should == "A508956A847F"    
    profile.created.should == DateTime.new(2008,7,24,10,49,23)
    profile.modified.should == DateTime.new(2008,7,24,10,50,23)
  end
  
  it "should parse XML data correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/profiles").and_return('<?xml version="1.0" encoding="UTF-8"?><Resources><ProfilesResource><Profiles><Profile created="2008-07-24 10:45:08.0" modified="2008-07-24 10:55:08.0" uid="B59C2AA75C7F"><Path/><Name/><Environment uid="5F5887BCF726"/><Permission created="2008-07-24 10:45:08.0" modified="2008-07-24 10:45:08.0" uid="44406616CCAB"><Environment uid="5F5887BCF726"/><Name>amee</Name><Username>floppy</Username></Permission></Profile><Profile created="2008-07-22 13:10:59.0" modified="2008-07-22 13:10:59.0" uid="59D8E437FA70"><Path/><Name/><Environment uid="5F5887BCF726"/><Permission created="2008-07-22 13:10:59.0" modified="2008-07-22 13:10:59.0" uid="EFE285A403D0"><Environment uid="5F5887BCF726"/><Name>amee</Name><Username>floppy</Username></Permission></Profile></Profiles><Pager><Start>0</Start><From>1</From><To>2</To><Items>2</Items><CurrentPage>1</CurrentPage><RequestedPage>1</RequestedPage><NextPage>-1</NextPage><PreviousPage>-1</PreviousPage><LastPage>1</LastPage><ItemsPerPage>10</ItemsPerPage><ItemsFound>2</ItemsFound></Pager></ProfilesResource></Resources>')
    profile = AMEE::Profile.list(connection)[0]
    profile.uid.should == "B59C2AA75C7F"
    profile.name.should == "B59C2AA75C7F"
    profile.path.should == "B59C2AA75C7F"    
    profile.created.should == DateTime.new(2008,7,24,10,45,8)
    profile.modified.should == DateTime.new(2008,7,24,10,55,8)
  end

end
