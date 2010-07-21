require File.dirname(__FILE__) + '/spec_helper.rb'

TestSeriesOne=[[AMEE::Epoch,1],[AMEE::Epoch+1,2],[AMEE::Epoch+3,4]]
TestSeriesTwo=[[AMEE::Epoch,2],[AMEE::Epoch+1,6],[AMEE::Epoch+5,7],[AMEE::Epoch+9,11]]

MockResourcePath="/data/transport/plane/generic/AD63A83B4D41/kgCO2PerPassengerJourney"
MockDataItemPath="/data/transport/plane/generic/AD63A83B4D41"
MockResourceXML='<Resources><DataItemValueResource><ItemValues>'+
  '<ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+AMEE::Epoch.xmlschema+'</StartDate><Value>1</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DOUBLE</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/>'+
  '<ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4922"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+(AMEE::Epoch+1).xmlschema+'</StartDate><Value>2</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DOUBLE</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/>'+
  '<ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4923"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+(AMEE::Epoch+3).xmlschema+'</StartDate><Value>4</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DOUBLE</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/>'+
  '</ItemValues></DataItemValueResource></Resources>'
MockResourceJSON='{"dataItem":{"uid":"AD63A83B4D41"},"itemValues":['+
  ' {"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+AMEE::Epoch.xmlschema+'","value":"1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
  ',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+(AMEE::Epoch+1).xmlschema+'","value":"2","uid":"127612FA4922","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
  ',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+(AMEE::Epoch+3).xmlschema+'","value":"4","uid":"127612FA4923","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
  ']}'
MockResourceXMLTwo='<Resources><DataItemValueResource><ItemValues>'+
  '<ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+AMEE::Epoch.xmlschema+'</StartDate><Value>1</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DOUBLE</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/>'+
  '<ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4922"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+(AMEE::Epoch+1).xmlschema+'</StartDate><Value>6</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DOUBLE</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/>'+
  '<ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4924"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+(AMEE::Epoch+5).xmlschema+'</StartDate><Value>7</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DOUBLE</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/>'+
  '<ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4925"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+(AMEE::Epoch+9).xmlschema+'</StartDate><Value>11</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DOUBLE</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/>'+
  '</ItemValues></DataItemValueResource></Resources>'
MockResourceJSONTwo='{"dataItem":{"uid":"AD63A83B4D41"},"itemValues":['+
  ' {"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+AMEE::Epoch.xmlschema+'","value":"1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
  ',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+(AMEE::Epoch+1).xmlschema+'","value":"6","uid":"127612FA4922","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
  ',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+(AMEE::Epoch+5).xmlschema+'","value":"7","uid":"127612FA4924","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
  ',{"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+(AMEE::Epoch+9).xmlschema+'","value":"11","uid":"127612FA4925","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
  ']}'
MockResourceXMLSingle='<Resources><DataItemValueResource><ItemValue Created="2007-08-01 09:00:41.0" Modified="2007-08-01 09:00:41.0" uid="127612FA4921"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><StartDate>'+AMEE::Epoch.xmlschema+'</StartDate><Value>1</Value><ItemValueDefinition uid="653828811D42"><Path>kgCO2PerPassengerJourney</Path><Name>kgCO2 Per Passenger Journey</Name><FromProfile>false</FromProfile><FromData>true</FromData><ValueDefinition uid="8CB8A1789CD6"><Name>kgCO2PerJourney</Name><ValueType>DOUBLE</ValueType></ValueDefinition></ItemValueDefinition><DataItem uid="AD63A83B4D41"/></ItemValue><DataItem uid="AD63A83B4D41"/></DataItemValueResource>'+
 '</Resources>'
MockResourceJSONSingle='{"dataItem":{"uid":"AD63A83B4D41"},"itemValue":'+
  ' {"item":{"uid":"AD63A83B4D41"},"modified":"2007-08-01 09:00:41.0","created":"2007-08-01 09:00:41.0","startDate":"'+AMEE::Epoch.xmlschema+'","value":"1","uid":"127612FA4921","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey","itemValueDefinition":{"valueDefinition":{"valueType":"DOUBLE","uid":"8CB8A1789CD6","name":"kgCO2PerJourney"},"uid":"653828811D42","path":"kgCO2PerPassengerJourney","name":"kgCO2 Per Passenger Journey"}}'+
   '}'


describe AMEE::Data::ItemValueHistory do

  before(:each) do
    @history = AMEE::Data::ItemValueHistory.new
  end

  it "should NOT have common AMEE object properties" do
    # we can't be an AMEE object, since we have a set of UIDs, not one UID
    @history.is_a?(AMEE::Data::Object).should be_false
  end

  it "should have an array of ItemValue objects" do
    @history.should respond_to(:values)
  end

  it "should be able to return a time series" do
    @history.should respond_to(:series)
  end

  it "should have a type" do
    @history.should respond_to(:type)
  end

  it "can be created with a type, and a time-value pairs array" do
    series=TestSeriesOne
    type = "TEXT"
    @history = AMEE::Data::ItemValueHistory.new(:series => series, :type => type)
    @history.series.should == series
    @history.type.should == type
    @history.values[0].is_a?(AMEE::Data::ItemValue).should be_true
    @history.values[0].value.should == 1
    @history.values[0].start_date.should == AMEE::Epoch
  end

  it "can be created by pushing to the array of item values" do
    series=TestSeriesOne
    type = "TEXT"
    @history = AMEE::Data::ItemValueHistory.new(:type=>type)
    @history.series.should == []
    @history.type.should == type
    @fstvalue = AMEE::Data::ItemValue.new(:type=>type,:value=>1,:start_date=>AMEE::Epoch)
    @sndvalue = AMEE::Data::ItemValue.new(:type=>type,:value=>2,:start_date=>AMEE::Epoch+1)
    @trdvalue = AMEE::Data::ItemValue.new(:type=>type,:value=>4,:start_date=>AMEE::Epoch+3)
    @history.values.push @fstvalue
    @history.values.push @sndvalue
    @history.values.push @trdvalue
    @history.values[0].is_a?(AMEE::Data::ItemValue).should be_true
    @history.values[0].value.should == 1
    @history.values[0].start_date.should == AMEE::Epoch
    @history.series.should == series
  end

  it "should support DOUBLE data type" do
    @history = AMEE::Data::ItemValueHistory.new(:series => TestSeriesOne, :type => "DOUBLE")
    @history.series.should == TestSeriesOne
  end

  it "should support TEXT data type" do
    @history = AMEE::Data::ItemValueHistory.new(:series => TestSeriesOne, :type => "TEXT")
    @history.series.should == TestSeriesOne
  end

  it "allows value to be changed after creation" do
    series=TestSeriesOne
    type = "TEXT"
    @history = AMEE::Data::ItemValueHistory.new(:series => series, :type => type)
    @history.series.should == series
    series = TestSeriesTwo
    @history.series = series
    @history.series.should == series
    @history.values[1].value.should == 6
  end

  it "allows item values to be found by time" do
    series=TestSeriesTwo
    type = "TEXT"
    @history = AMEE::Data::ItemValueHistory.new(:series => series, :type => type)
    @value=@history.value_at(AMEE::Epoch+5)
    @value.value.should == 7
    lambda {
      @history.value_at(AMEE::Epoch+6)
    }.should raise_error
    @history.values_at([AMEE::Epoch+1,AMEE::Epoch+9]).length.should eql 2
  end

end

describe AMEE::Data::ItemValueHistory, "when comparing to another history" do
  before(:each) do
    @historyone = AMEE::Data::ItemValueHistory.new(:series=>TestSeriesOne)
    @historytwo = AMEE::Data::ItemValueHistory.new(:series=>TestSeriesTwo)
    @comparison=@historytwo.compare(@historyone)
  end

  it "should be able to compare histories" do
    @comparison.should be_a Hash
    @comparison[:deletions].should be_a Array
    @comparison[:updates].should be_a Array
    @comparison[:insertions].should be_a Array
  end

  it "should return an array of items to update" do
    # note comparison list isnt order stable so sort here for test
    @changes=@comparison[:updates].sort{|x,y| x.start_date <=> y.start_date}
    @changes.length.should eql 2
    @changes[1].value.should eql 6
    @changes[1].start_date.should eql AMEE::Epoch+1
    @changes[0].start_date.should eql AMEE::Epoch
    @changes[0].value.should eql 2

  end
  it "should return an array of items to create" do
    @changes=@comparison[:insertions].sort{|x,y| x.start_date <=> y.start_date}
    @changes.length.should eql 2
    @changes[0].start_date.should eql AMEE::Epoch+5
    @changes[1].start_date.should eql AMEE::Epoch+9
    @changes[0].value.should eql 7
    @changes[1].value.should eql 11
  end
  it "should return an array of items to delete" do
    @changes=@comparison[:deletions].sort{|x,y| x.start_date <=> y.start_date}
    @changes.length.should eql 1
    @changes[0].start_date.should eql AMEE::Epoch+3
  end

end

describe AMEE::Data::ItemValueHistory, "with an authenticated connection" do

  it "should parse XML correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(MockResourcePath,:valuesPerPage=>2).
      and_return(flexmock(:body => MockResourceXML))
    @history = AMEE::Data::ItemValueHistory.get(connection, MockResourcePath)
    @history.series.should == TestSeriesOne
    @fstvalue=@history.values[0]
    @sndvalue=@history.values[1]
    @fstvalue.uid.should == "127612FA4921"
    @sndvalue.uid.should == "127612FA4922"
    @fstvalue.name.should == "kgCO2 Per Passenger Journey"
    @fstvalue.full_path.should == MockResourcePath
    @fstvalue.created.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.modified.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.type.should == "DOUBLE"
    @history.series.should == TestSeriesOne
    @history.type.should == "DOUBLE"
  end

  it "should parse JSON correctly" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(MockResourcePath,:valuesPerPage=>2).and_return(flexmock(:body => MockResourceJSON))
    @history = AMEE::Data::ItemValueHistory.get(connection, MockResourcePath)
    @fstvalue=@history.values[0]
    @sndvalue=@history.values[1]
    @fstvalue.uid.should == "127612FA4921"
    @sndvalue.uid.should == "127612FA4922"
    @fstvalue.name.should == "kgCO2 Per Passenger Journey"
    @fstvalue.full_path.should == MockResourcePath
    @fstvalue.created.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.modified.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.type.should == "DOUBLE"
    @history.series.should == TestSeriesOne
    @history.type.should == "DOUBLE"
  end

  it "should parse JSON correctly if theres only one point" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(MockResourcePath,:valuesPerPage=>2).and_return(flexmock(:body => MockResourceJSONSingle))
    @history = AMEE::Data::ItemValueHistory.get(connection, MockResourcePath)
    @fstvalue=@history.values[0]
    @fstvalue.uid.should == "127612FA4921"
    @fstvalue.name.should == "kgCO2 Per Passenger Journey"
    @fstvalue.full_path.should == MockResourcePath
    @fstvalue.created.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.modified.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.type.should == "DOUBLE"
    @history.series.should == [[AMEE::Epoch,1]]
    @history.type.should == "DOUBLE"
  end

  it "should parse XML correctly if theres only one point" do
    connection = flexmock "connection"
    connection.should_receive(:get).with(MockResourcePath,:valuesPerPage=>2).and_return(flexmock(:body => MockResourceXMLSingle))
    @history = AMEE::Data::ItemValueHistory.get(connection, MockResourcePath)
    @fstvalue=@history.values[0]
    @fstvalue.uid.should == "127612FA4921"
    @fstvalue.name.should == "kgCO2 Per Passenger Journey"
    @fstvalue.full_path.should == MockResourcePath
    @fstvalue.created.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.modified.should == DateTime.new(2007,8,1,9,00,41)
    @fstvalue.type.should == "DOUBLE"
    @history.series.should == [[AMEE::Epoch,1]]
    @history.type.should == "DOUBLE"
  end

  it "should fail gracefully with incorrect XML data" do
    connection = flexmock "connection"
    xml = '<?xml version="1.0" encoding="UTF-8"?><Resources></Resources>'
    connection.should_receive(:get).with("/data",:valuesPerPage=>2).and_return(flexmock(:body => xml))
    lambda{AMEE::Data::ItemValueHistory.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValueHistory from XML. Check that your URL is correct.\n#{xml}")
  end

  it "should fail gracefully with incorrect JSON data" do
    connection = flexmock "connection"
    json = '{}'
    connection.should_receive(:get).with("/data",:valuesPerPage=>2).and_return(flexmock(:body => json))
    lambda{AMEE::Data::ItemValueHistory.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValue from JSON. Check that your URL is correct.\n")
  end

  it "should fail gracefully on other errors" do
    connection = flexmock "connection"
    connection.should_receive(:get).with("/data",:valuesPerPage=>2).and_raise("unidentified error")
    lambda{AMEE::Data::ItemValueHistory.get(connection, "/data")}.should raise_error(AMEE::BadData, "Couldn't load DataItemValueHistory. Check that your URL is correct.")
  end

  it "should fail gracefully if create series without epoch" do
    @history = AMEE::Data::ItemValueHistory.new()
    lambda{@history.series=[[AMEE::Epoch+1,5]]}.should raise_error(AMEE::BadData,"Series must have initial (Epoch) value")
  end

end

describe AMEE::Data::ItemValueHistory, "after loading" do

  before(:each) do
    @path = MockResourcePath
    @connection = flexmock "connection"
    @connection.should_receive(:get).with(@path,:valuesPerPage=>2).and_return(flexmock(:body => MockResourceJSON))
    @val = AMEE::Data::ItemValueHistory.get(@connection, @path)
  end

  it "can have series changed and saved back to server" do
    @connection.should_receive(:put).with(MockDataItemPath+"/127612FA4921", :value => 2).once.and_return(flexmock(:body => ''))
    # note this one shouldn't include a start date as it is the epoch point
    @connection.should_receive(:put).with(MockDataItemPath+"/127612FA4922", :value => 6, :startDate => AMEE::Epoch+1).once.and_return(flexmock(:body => ''))
    @connection.should_receive(:delete).with(MockDataItemPath+"/127612FA4923").once.and_return(flexmock(:body => ''))
    @connection.should_receive(:post).with(MockDataItemPath,
      :kgCO2PerPassengerJourney => 7, :startDate => AMEE::Epoch+5).once.and_return({'Location'=>'http://foo.com/'})
    @connection.should_receive(:post).with(MockDataItemPath,
      :kgCO2PerPassengerJourney => 11, :startDate => AMEE::Epoch+9).once.and_return({'Location'=>'http://foo.com/'})
    lambda {
      @val.series = TestSeriesTwo
      @val.save!
    }.should_not raise_error
  end

  it "can have series changed and saved back to server (using SSL)" do
    @connection.should_receive(:put).with(MockDataItemPath+"/127612FA4921", :value => 2).once.and_return(flexmock(:body => ''))
    # note this one shouldn't include a start date as it is the epoch point
    @connection.should_receive(:put).with(MockDataItemPath+"/127612FA4922", :value => 6, :startDate => AMEE::Epoch+1).once.and_return(flexmock(:body => ''))
    @connection.should_receive(:delete).with(MockDataItemPath+"/127612FA4923").once.and_return(flexmock(:body => ''))
    @connection.should_receive(:post).with(MockDataItemPath,
      :kgCO2PerPassengerJourney => 7, :startDate => AMEE::Epoch+5).once.and_return({'Location'=>'https://foo.com/'})
    @connection.should_receive(:post).with(MockDataItemPath,
      :kgCO2PerPassengerJourney => 11, :startDate => AMEE::Epoch+9).once.and_return({'Location'=>'https://foo.com/'})
    lambda {
      @val.series = TestSeriesTwo
      @val.save!
    }.should_not raise_error
  end

  it "cannot create a new series (unsupported by platform)" do
    lambda {
      @val.series = TestSeriesTwo
      @val.create!
    }.should raise_error(AMEE::NotSupported,"Cannot create a Data Item Value History from scratch: at least one data point must exist when the DI is created")
  end

  it "cannot delete an entire series (unsupported by platform)" do
    lambda {
      @val.delete!
    }.should raise_error(AMEE::NotSupported,"Cannot delete all of history: at least one data point must always exist.")
  end

end
