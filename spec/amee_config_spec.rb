# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.
require 'spec_helper.rb'
require 'pry'

describe AMEE::Config do

  # make sure environment variables are clear for each test
  before(:each) do
    ENV['AMEE_SERVER'] = nil
    ENV['AMEE_USERNAME'] = nil
    ENV['AMEE_PASSWORD'] = nil
  end

  context "loading config details from the environment"

  it "should let us use ENV variables so we can use heroku" do
    # fake the ENV variables setting
    ENV['AMEE_SERVER'] = "stage.amee.com"
    ENV['AMEE_USERNAME'] = "joe_shmoe"
    ENV['AMEE_PASSWORD'] = "top_sekrit123"

    amee_config = AMEE::Config.setup()

    amee_config[:username].should eq "joe_shmoe"
    amee_config[:server].should eq "stage.amee.com"
    amee_config[:password].should eq "top_sekrit123"

  end

  context "loading config details from a yaml file" do

    it "so we don't rely on heroku ALL the time" do
      
      config_path = File.dirname(__FILE__)+'/fixtures/rails_config.yml'

      amee_config = AMEE::Config.setup(config_path, 'test')
      
      amee_config[:username].should eq "joe_shmoe"
      amee_config[:server].should eq "stage.amee.com"
      amee_config[:password].should eq "top_sekrit123"
      
    end
  end


end