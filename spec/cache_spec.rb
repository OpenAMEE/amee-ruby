# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'spec_helper.rb'
require 'ostruct'

describe AMEE::Connection do

  describe 'without caching' do

    it "doesn't cache GET requests" do
      VCR.use_cassette("AMEE_Connection_Caching_Off/logging_in") do
        @connection = AMEE::Connection.new("stage.amee.com", "amee_ruby_vcr_v2", "8nkj8rm7")
      end

      VCR.use_cassette("AMEE_Connection_Caching_Off/authenticating") do
        @connection.authenticate
      end
      
      VCR.use_cassette("AMEE_Connection_Caching_Off/first_request") do
        @first_response = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      end

      VCR.use_cassette("AMEE_Connection_Caching_Off/second_request") do
        @second_response = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      end
    
      # We're checking to see if we actually have a returned object.
      # If there's no response in the VCR cassette, then we can't build the object
      # to check if it responds to the methods below
      @first_response.should respond_to(:uid)
      @first_response.should respond_to(:name)

      # Likewise with the second response. There needs to be a yaml file to read from to
      # build the object. 
      File.exists?('cassettes/AMEE_Connection_Caching_Off/second_request.yml').should be true
      # Then we check for the same content to see we can build the object needed.
      @second_response.should respond_to(:uid)
      @second_response.should respond_to(:name)

    end

  end

  describe 'with caching' do

    def setup_connection
      VCR.use_cassette("AMEE_Connection_Caching_On/logging_in") do
        @connection = AMEE::Connection.new("stage.amee.com", "amee_ruby_vcr_v2", "8nkj8rm7", :cache => :memory_store)
      end

      VCR.use_cassette("AMEE_Connection_Caching_On/authenticating") do
        @connection.authenticate
      end
      
      VCR.use_cassette("AMEE_Connection_Caching_On/first_request") do
        @first_response = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      end
    end

    it "caches GET requests" do

      setup_connection

      VCR.use_cassette("AMEE_Connection_Caching_On/second_request") do
        @second_response = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      end

      # We're checking to see if we actually have a returned object.
      # If there's no response in the VCR cassette, then we can't build the object
      # to check if it responds to the methods below
      @first_response.should respond_to(:uid)
      @first_response.should respond_to(:name)

      # Likewise with the second response. When caching is on, we don't want to see a second 
      # request being recorded, but we still want to see the object being built
      File.exists?('cassettes/AMEE_Connection_Caching_On/second_request.yml').should be false
      # Then we check for the same content to see we can build the object needed.
      @second_response.should respond_to(:uid)
      @second_response.should respond_to(:name)
    end

    it "allows complete cache clear" do

      setup_connection
      @connection.expire_all

      VCR.use_cassette("AMEE_Connection_Caching_clear_all/second_request") do
        @second_response = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      end

      File.exists?('cassettes/AMEE_Connection_Caching_clear_all/second_request.yml').should be true      
      @second_response.should respond_to(:uid)
      @second_response.should respond_to(:name)
    end

    it "allows manual cache expiry for objects" do
      setup_connection
      @first_response.expire_cache

      VCR.use_cassette("AMEE_Connection_Caching_clear_manually/second_request") do
        @second_response = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      end

      File.exists?('cassettes/AMEE_Connection_Caching_clear_manually/second_request.yml').should be true      
      @second_response.should respond_to(:uid)
      @second_response.should respond_to(:name)
    end

    it "object expiry invalidates objects further down the tree" do
      setup_connection
      
      VCR.use_cassette("AMEE_Connection_Caching_further_down_tree/second_request") do
        @second_response = @first_response.item :label => 'biodiesel'
        @first_response.expire_cache
        @third_response = @first_response.item :label => 'biodiesel'
      end

      File.exists?('cassettes/AMEE_Connection_Caching_further_down_tree/second_request.yml').should be true      
      @second_response.label.should == "biodiesel"
      @third_response.label.should == "biodiesel"

    end
    
    it "removes special characters from cache keys, include slashes" do
      setup_connection
      @connection.send(:cache_key, "/%cache/$4/%20test").should eql 'stage.amee.com_cache_4_20test'
    end
    
    it "works around rails 3 file store cache key bug by disallowing cache keys with length 229/230" do
      setup_connection
      cache = ActiveSupport::Cache.lookup_store(:file_store, '/tmp/amee-ruby-cache-test')
      # test caching of lots of key lengths
      (200..500).each do |i|
        # Generate cache key
        test_str = 'a' * i
        key = @connection.send(:cache_key, test_str)
        lambda { cache.write(key, {}) }.should_not raise_error
        cache.delete(key)
      end
    end


    describe 'and automatic invalidation' do

      def test_invalidation_sequence(interactions)
        setup_connection
        flexmock(@connection) do |mock|
          interactions.each do |path, action, result|
            mock.should_receive(:run_request).once.and_return(OpenStruct.new(:code => '200', :body => path)) if result
          end
        end
        interactions.each do |path, action, result|
          if action
            @connection.send(action, path).body.should == path
          end
        end
      end

      it "handles PUT requests" do
        VCR.use_cassette("AMEE_Connection_Caching/automatic_invalidation_for_put") do
        test_invalidation_sequence([
          # Fill the cache
          ["/parent/object", :get, true],
          ["/parent", :get, true],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, true],
          ["/uncle/cousin", :get, true],
          ["/uncle", :get, true],
          # Do a PUT
          ["/parent/object", :put, true],
          # Check that cache is cleared in the right places
          ["/parent/object", :get, true],
          ["/parent", :get, true],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, true],
          ["/uncle/cousin", :get, false],
          ["/uncle", :get, false],
        ])
        end
      end

      it "handles POST requests" do
        VCR.use_cassette("AMEE_Connection_Caching/automatic_invalidation_for_post") do
        test_invalidation_sequence([
          # Fill the cache
          ["/parent/object", :get, true],
          ["/parent", :get, true],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, true],
          ["/uncle/cousin", :get, true],
          ["/uncle", :get, true],
          # Do a POST
          ["/parent/object", :post, true],
          # Check that cache is cleared in the right places
          ["/parent/object", :get, true],
          ["/parent", :get, false],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, false],
          ["/uncle/cousin", :get, false],
          ["/uncle", :get, false],
        ])
      end
      end

      it "handles DELETE requests" do
        VCR.use_cassette("AMEE_Connection_Caching/automatic_invalidation_for_delete") do
        test_invalidation_sequence([
          # Fill the cache
          ["/parent/object", :get, true],
          ["/parent", :get, true],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, true],
          ["/uncle/cousin", :get, true],
          ["/uncle", :get, true],
          # Do a DELETE
          ["/parent/object", :delete, true],
          # Check that cache is cleared in the right places
          ["/parent/object", :get, true],
          ["/parent", :get, true],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, true],
          ["/uncle/cousin", :get, false],
          ["/uncle", :get, false],
        ])
      end
      end

    end
    
  end

end
