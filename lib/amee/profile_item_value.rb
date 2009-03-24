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
        when "DECIMAL"
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
        raise AMEE::BadData.new("Couldn't load ProfileItemValue from JSON. Check that your URL is correct.")
      end
      
      def self.from_xml(xml, path)
        # Read XML
        doc = REXML::Document.new(xml)
        data = {}
        data[:uid] = REXML::XPath.first(doc, "/Resources/ProfileItemValueResource/ItemValue/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, "/Resources/ProfileItemValueResource/ItemValue/@Created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/Resources/ProfileItemValueResource/ItemValue/@Modified").to_s)
        data[:name] = REXML::XPath.first(doc, '/Resources/ProfileItemValueResource/ItemValue/Name').text
        data[:path] = path.gsub(/^\/profiles/, '')
        data[:value] = REXML::XPath.first(doc, '/Resources/ProfileItemValueResource/ItemValue/Value').text
        data[:unit] = REXML::XPath.first(doc, '/Resources/ProfileItemValueResource/ItemValue/Unit').text rescue nil
        data[:per_unit] = REXML::XPath.first(doc, '/Resources/ProfileItemValueResource/ItemValue/PerUnit').text rescue nil
        data[:type] = REXML::XPath.first(doc, '/Resources/ProfileItemValueResource/ItemValue/ItemValueDefinition/ValueDefinition/ValueType').text
        data[:from_profile] = REXML::XPath.first(doc, '/Resources/ProfileItemValueResource/ItemValue/ItemValueDefinition/FromProfile').text == "true" ? true : false
        data[:from_data] = REXML::XPath.first(doc, '/Resources/ProfileItemValueResource/ItemValue/ItemValueDefinition/FromData').text == "true" ? true : false
        # Create object
        ItemValue.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItemValue from XML. Check that your URL is correct.")
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
        raise AMEE::BadData.new("Couldn't load ProfileItemValue. Check that your URL is correct.")
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