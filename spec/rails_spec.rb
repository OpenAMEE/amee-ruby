require File.dirname(__FILE__) + '/spec_helper.rb'
require 'amee/rails'
require 'activerecord'

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

    it "should have save_with_amee and save_without_amee functions" do
      @test.klass.method_defined?(:save_with_amee).should be_true
      @test.klass.method_defined?(:save_without_amee).should be_true
    end

    it "should have an amee_save function" do
      @test.klass.method_defined?(:amee_save).should be_true
    end

    it "should have an amee_destroy function" do
      @test.klass.method_defined?(:amee_destroy).should be_true
    end

  end

end