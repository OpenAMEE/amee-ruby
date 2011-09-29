# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'

Testcativduid="5648C049F599"
Testrvduid="C21026DD57C5"
describe AMEE::Admin::ReturnValueDefinition, "with an authenticated XML connection" do

  #  # find UID for test/jh/ameem/preexistent
  #  it "should work" do
  #    connection=AMEE::Connection.new('platform-science.amee.com','admin','r41n80w')
  #    testcativduid="#{Testcativduid}"
  #  # get the current list of RVDs
  #    list=AMEE::Admin::ReturnValueDefinitionList.new(connection,testcativduid)
  #    pp list
  #  # add an RVD
  #    AMEE::Admin::ReturnValueDefinition.create(connection,testcativduid,
  #      :type=>'CO2',:unit=>'kg',:perUnit=>'month',:valueDefinition=>'45433E48B39F')
  #  # re-get the list of RVDs
  #    list=AMEE::Admin::ReturnValueDefinitionList.new(connection,testcativduid)
  #    pp list
  #  # delete the RVDs
  #    list.each do |rvd|
  #      AMEE::Admin::ReturnValueDefinition.delete(connection,testcativduid,rvd)
  #    end
  #  end



  it "should index a list of return value definitions" do
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:v3_get).
      with("/#{AMEE_API_VERSION}/definitions/#{Testcativduid}/returnvalues;full", {:resultLimit=>10, :resultStart=>0}).
      and_return(fixture('return_value_definition_list.xml')).once
    list=AMEE::Admin::ReturnValueDefinitionList.new(connection,Testcativduid)
    list.should have(3).items
  end
  it "should return an empty list when there are no return value definitions" do    
    connection = flexmock "connection"
    connection.should_receive(:retries).and_return(0).once
    connection.should_receive(:v3_get).
      with("/#{AMEE_API_VERSION}/definitions/#{Testcativduid}/returnvalues;full", {:resultLimit=>10, :resultStart=>0}).
      and_return(fixture('empty_return_value_definition_list.xml')).once
    list=AMEE::Admin::ReturnValueDefinitionList.new(connection,Testcativduid)
    list.should have(0).items
  end
  it "should create a return value definition" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).
      with("/#{AMEE_API_VERSION}/definitions/#{Testcativduid}/returnvalues/#{Testrvduid};full", {}).
      and_return(fixture('return_value_definition.xml')).once
    connection.should_receive(:v3_post).
      with("/#{AMEE_API_VERSION}/definitions/#{Testcativduid}/returnvalues",  
      {:type=>"CO2", :valueDefinition=>"45433E48B39F",
        :returnobj=>true, :unit=>"kg", :perUnit=>"month"}).
      and_return({'Location'=>"///#{AMEE_API_VERSION}/definitions/#{Testcativduid}/returnvalues/#{Testrvduid}"}).once
    rvd=AMEE::Admin::ReturnValueDefinition.create(connection,Testcativduid,
      :type=>'CO2',:unit=>'kg',:perUnit=>'month')
    
    rvd.uid.should eql Testrvduid
    rvd.unit.should eql 'kg'
    rvd.perunit.should eql 'month'
    rvd.type.should eql 'CO2'
  end
  it "should read a return value definition" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).
      with("/#{AMEE_API_VERSION}/definitions/#{Testcativduid}/returnvalues/#{Testrvduid};full", {}).
      and_return(fixture('return_value_definition.xml')).once
    rvd=AMEE::Admin::ReturnValueDefinition.load(connection,Testcativduid,Testrvduid)
   
    rvd.uid.should eql Testrvduid
    rvd.unit.should eql 'kg'
    rvd.perunit.should eql 'month'
    rvd.type.should eql 'CO2'
  end
  it "should delete a return value definition" do
    connection = flexmock "connection"
    connection.should_receive(:v3_get).
      with("/#{AMEE_API_VERSION}/definitions/#{Testcativduid}/returnvalues/#{Testrvduid};full", {}).
      and_return(fixture('return_value_definition.xml')).once
    connection.should_receive(:v3_delete).
      with("/#{AMEE_API_VERSION}/definitions/#{Testcativduid}/returnvalues/#{Testrvduid}").once
    connection.should_receive(:timeout=)
     connection.should_receive(:timeout)
    rvd=AMEE::Admin::ReturnValueDefinition.load(connection,Testcativduid,Testrvduid)
    AMEE::Admin::ReturnValueDefinition.delete(connection,Testcativduid,rvd)
  end
end