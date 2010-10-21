require File.dirname(__FILE__) + '/spec_helper.rb'
require 'ostruct'

describe AMEE::Connection do

  describe 'without caching' do

    it "doesn't cache GET requests" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).twice.and_return(flexmock(:code => '200', :body => fixture('data_home_energy_quantity.xml')))
        mock.should_receive(:finish => nil)
      end
      @connection = AMEE::Connection.new("server.example.com", "username", "password")
      c = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      c = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
    end

  end

  describe 'with caching' do

    def setup_connection
      @connection = AMEE::Connection.new("server.example.com", "username", "password", :cache => :memory_store)
    end

    it "caches GET requests" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).once.and_return(OpenStruct.new(:code => '200', :body => fixture('data_home_energy_quantity.xml')))
        mock.should_receive(:finish => nil)
      end
      setup_connection
      c = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      c = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
    end

    it "allows complete cache clear" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).twice.and_return(OpenStruct.new(:code => '200', :body => fixture('data_home_energy_quantity.xml')))
        mock.should_receive(:finish => nil)
      end
      setup_connection
      c = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      @connection.expire_all
      c = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
    end

    it "allows manual cache expiry for objects" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).twice.and_return(OpenStruct.new(:code => '200', :body => fixture('data_home_energy_quantity.xml')))
        mock.should_receive(:finish => nil)
      end
      setup_connection
      c = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      c.expire_cache
      c = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
    end

    it "object expiry invalidates objectes further down the tree" do
      flexmock(Net::HTTP).new_instances do |mock|
        mock.should_receive(:start => nil)
        mock.should_receive(:request).once.and_return(OpenStruct.new(:code => '200', :body => fixture('data_home_energy_quantity.xml')))
        mock.should_receive(:request).twice.and_return(OpenStruct.new(:code => '200', :body => fixture('data_home_energy_quantity_biodiesel.xml')))
        mock.should_receive(:finish => nil)
      end
      setup_connection
      c = AMEE::Data::Category.get(@connection, '/data/home/energy/quantity')
      i = c.item :label => 'biodiesel'
      c.expire_cache
      i = c.item :label => 'biodiesel'
    end

    describe 'and automatic invalidation' do

      def test_invalidation_sequence(interactions)
        flexmock(Net::HTTP).new_instances do |mock|
          mock.should_receive(:start => nil)
          interactions.each do |path, action, result|
            mock.should_receive(:request).once.and_return(OpenStruct.new(:code => '200', :body => path)) if result
          end
          mock.should_receive(:finish => nil)
        end
        setup_connection
        interactions.each do |path, action, result|
          if action
            @connection.send(action, path).body.should == path
          end
        end
      end

      it "handles PUT requests" do
        test_invalidation_sequence([
          ["/parent/object", :get, true],
          ["/parent", :get, true],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, true],
          ["/uncle/cousin", :get, true],
          ["/uncle", :get, true],
          ["/parent/object", :put, true],
          ["/parent/object", :get, true],
          ["/parent", :get, true],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, true],
          ["/uncle/cousin", :get, false],
          ["/uncle", :get, false],
        ])
      end

      it "handles POST requests" do
        test_invalidation_sequence([
          ["/parent/object", :get, true],
          ["/parent", :get, true],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, true],
          ["/uncle/cousin", :get, true],
          ["/uncle", :get, true],
          ["/parent/object", :post, true],
          ["/parent/object", :get, true],
          ["/parent", :get, false],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, false],
          ["/uncle/cousin", :get, false],
          ["/uncle", :get, false],
        ])
      end

      it "handles DELETE requests" do
        test_invalidation_sequence([
          ["/parent/object", :get, true],
          ["/parent", :get, true],
          ["/parent/object/child", :get, true],
          ["/parent/sibling", :get, true],
          ["/uncle/cousin", :get, true],
          ["/uncle", :get, true],
          ["/parent/object", :delete, true],
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
