# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  module Profile
    class ItemValue < AMEE::Profile::Object

      def initialize(data = {})
        @value = data ? data[:value] : nil
        @type = data ? data[:type] : nil
        @unit = data ? data[:unit] : nil
        @per_unit = data ? data[:per_unit] : nil
        @from_profile = data ? data[:from_profile] : nil
        @from_data = data ? data[:from_data] : nil
        super
      end

      attr_reader :type
      attr_accessor :unit
      attr_accessor :per_unit

      def value
        case type
        when "DECIMAL", "DOUBLE"
          @value.to_f
        else
          @value
        end
      end

      def value=(val)
        @value = val
      end

      def from_profile?
        @from_profile
      end

      def from_data?
        @from_data
      end

      def self.from_json(json, path)
        # Read JSON
        doc = JSON.parse(json)['itemValue']
        data = {}
        data[:uid] = doc['uid']
        data[:created] = DateTime.parse(doc['created'])
        data[:modified] = DateTime.parse(doc['modified'])
        data[:name] = doc['name']
        data[:path] = path.gsub(/^\/profiles/, '')
        data[:value] = doc['value']
        data[:unit] = doc['unit']
        data[:per_unit] = doc['perUnit']
        data[:type] = doc['itemValueDefinition']['valueDefinition']['valueType']
        # Create object
        ItemValue.new(data)
      rescue 
        raise AMEE::BadData.new("Couldn't load ProfileItemValue from JSON. Check that your URL is correct.\n#{json}")
      end
      
      def self.from_xml(xml, path)
        # Read XML
        @doc = load_xml_doc(xml)
        data = {}
        data[:uid] = x("/Resources/ProfileItemValueResource/ItemValue/@uid")
        data[:created] = DateTime.parse(x("/Resources/ProfileItemValueResource/ItemValue/@Created"))
        data[:modified] = DateTime.parse(x("/Resources/ProfileItemValueResource/ItemValue/@Modified"))
        data[:name] = x('/Resources/ProfileItemValueResource/ItemValue/Name')
        data[:path] = path.gsub(/^\/profiles/, '')
        data[:value] = x('/Resources/ProfileItemValueResource/ItemValue/Value')
        data[:unit] = x('/Resources/ProfileItemValueResource/ItemValue/Unit')
        data[:per_unit] = x('/Resources/ProfileItemValueResource/ItemValue/PerUnit')
        data[:type] = x('/Resources/ProfileItemValueResource/ItemValue/ItemValueDefinition/ValueDefinition/ValueType')
        data[:from_profile] = x('/Resources/ProfileItemValueResource/ItemValue/ItemValueDefinition/FromProfile') == "true" ? true : false
        data[:from_data] = x('/Resources/ProfileItemValueResource/ItemValue/ItemValueDefinition/FromData') == "true" ? true : false
        # Create object
        ItemValue.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItemValue from XML. Check that your URL is correct.\n#{xml}")
      end

      def self.get(connection, path)
        # Load Profile from path
        response = connection.get(path).body
        # Parse data from response
        if response.is_json?
          value = ItemValue.from_json(response, path)
        else
          value = ItemValue.from_xml(response, path)
        end
        # Store connection in object for future use
        value.connection = connection
        # Done
        return value
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItemValue. Check that your URL is correct.\n#{response}")
      end

      def save!
        options = {:value => value}
        options[:unit] = unit if unit
        options[:perUnit] = per_unit if per_unit
        response = @connection.put(full_path, options).body
      end

    end
  end
end