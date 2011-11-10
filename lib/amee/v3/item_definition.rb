# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  module Admin
    class ItemDefinition < AMEE::Object

      include ParseHelper

      def initialize_with_v3(data = {})
        @usages = data[:usages] || []
        @algorithms = data[:algorithms] || {}
        initialize_without_v3(data)
      end
      alias_method_chain :initialize, :v3

      attr_accessor :usages, :algorithms

      def self.metaxmlpathpreamble
        '/Representation/ItemDefinition/'
      end

      def self.load(connection,uid,options={})
        ItemDefinition.v3_get(connection,uid,options)
      end

      def self.v3_get(connection, uid, options={})
        # Load data from path
        response = connection.v3_get("/#{AMEE::Connection.api_version}/definitions/#{uid};full", options)
        # Parse response
        item_definition = ItemDefinition.parse(connection, response, false)
        # Done
        return item_definition
      rescue
        raise AMEE::BadData.new("Couldn't load ItemDefinition. Check that your URL is correct.\n#{$!}\n#{response}")
      end

      def self.from_xml_with_v3(xml, is_list = true)
        return self.from_xml_without_v3(xml, is_list) if xml.include?('<Resources>')
        # Parse data from response into hash
        doc = load_xml_doc(xml)
        data = {}
        data[:uid] = x '@uid', :doc => doc, :meta => true
        data[:created] = DateTime.parse(x '@created', :doc => doc, :meta => true)
        data[:modified] = DateTime.parse(x '@modified', :doc => doc, :meta => true)
        data[:name] = x 'Name', :doc => doc, :meta => true
        data[:drillDown] = x('DrillDown', :doc => doc, :meta => true).split(",") rescue nil
        data[:usages] = [(x 'Usages/Usage/Name', :doc => doc, :meta => true)].flatten.delete_if{|x| x.nil?}
        data[:algorithms] = begin
          names = [(x 'Algorithms/Algorithm/Name', :doc => doc, :meta => true)].flatten.delete_if{|x| x.nil?}
          uids = [(x 'Algorithms/Algorithm/@uid', :doc => doc, :meta => true)].flatten.delete_if{|x| x.nil?}
          Hash[names.zip(uids)]
        end
        # Create object
        ItemDefinition.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ItemDefinition from XML. Check that your URL is correct.\n#{$!}\n#{xml}")
      end
      class << self
        alias_method_chain :from_xml, :v3
      end

      def save!
        save_options = {
          :usages => @usages.join(','),
          :name => @name
        }
        @connection.v3_put("/#{AMEE::Connection.api_version}/definitions/#{@uid}",save_options)
      end

      def expire_cache_with_v3
        @connection.expire_matching("/#{AMEE::Connection.api_version}/definitions/#{@uid}.*")
        expire_cache_without_v3
      end
      alias_method_chain :expire_cache, :v3

    end
  end
end
