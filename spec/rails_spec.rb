# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'
require 'amee/rails'
require 'active_record'

class Rails
  def self.env
    'test'
  end
  def self.root
    File.join(File.dirname(__FILE__),'fixtures')
  end
  def self.logger
    nil
  end
end

describe AMEE::Rails do

  class AMEETest < ActiveRecord::Base
    include AMEE::Rails
  end

  it "should add the has_amee_profile method to a class which includes it" do
    AMEETest.respond_to?(:has_amee_profile).should be_true
  end
  
  describe "using has_amee_profile" do

    class HasProfileTest < AMEETest
      has_amee_profile
    end

    before(:each) do
      @test = disconnected HasProfileTest
    end
    
    it "should have an amee_connection function" do
      @test.klass.method_defined?(:amee_connection).should be_true
    end

    it "should have an amee_create function" do
      @test.klass.method_defined?(:amee_create).should be_true
    end

    it "should have an amee_save function" do
      @test.klass.method_defined?(:amee_save).should be_true
    end

    it "should have an amee_destroy function" do
      @test.klass.method_defined?(:amee_destroy).should be_true
    end

  end

  describe "loads configuration file correctly" do
    
    it "should autoload config file when AMEE::Rails.connection is accessed" do
      x = AMEE::Rails.connection(:authenticate => false)
      x.server.should eql 'stage.amee.com'
      x.username.should eql 'username'
      x.password.should eql 'password'
    end

  end

end
