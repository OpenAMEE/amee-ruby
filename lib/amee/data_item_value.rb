module AMEE
  module Data
    class ItemValue < AMEE::Object

      def initialize(data = {})
        @value = data ? data[:value] : nil
        @type = data ? data[:type] : nil
        @from_profile = data ? data[:from_profile] : nil
        @from_data = data ? data[:from_data] : nil
        super
      end

      attr_reader :type

      def value
        case type
        when "DECIMAL"
          @value.to_f
        else
          @value
        end
      end

      def from_profile?
        @from_profile
      end
      
      def from_data?
        @from_data
      end
      
      def self.get(connection, path)
        # Load data from path
        response = connection.get(path)
        # Parse data from response
        data = {}
        if response.slice(0,1) == '{'
          # Read JSON
          doc = JSON.parse(response)['itemValue']
          data[:uid] = doc['uid']
          data[:created] = DateTime.parse(doc['created'])
          data[:modified] = DateTime.parse(doc['modified'])
          data[:name] = doc['name']
          data[:path] = path
          data[:value] = doc['value']
          data[:type] = doc['itemValueDefinition']['valueDefinition']['valueType']
        else
          # Read XML
          doc = REXML::Document.new(response)
          data[:uid] = REXML::XPath.first(doc, "/Resources/DataItemValueResource/ItemValue/@uid").to_s
          data[:created] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemValueResource/ItemValue/@Created").to_s)
          data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemValueResource/ItemValue/@Modified").to_s)
          data[:name] = REXML::XPath.first(doc, '/Resources/DataItemValueResource/ItemValue/Name').text
          data[:path] = path
          data[:value] = REXML::XPath.first(doc, '/Resources/DataItemValueResource/ItemValue/Value').text
          data[:type] = REXML::XPath.first(doc, '/Resources/DataItemValueResource/ItemValue/ItemValueDefinition/ValueDefinition/ValueType').text
          data[:from_profile] = REXML::XPath.first(doc, '/Resources/DataItemValueResource/ItemValue/ItemValueDefinition/FromProfile').text == "true" ? true : false
          data[:from_data] = REXML::XPath.first(doc, '/Resources/DataItemValueResource/ItemValue/ItemValueDefinition/FromData').text == "true" ? true : false
        end
        # Create item object
        item = ItemValue.new(data)
        # Store connection in object for future use
        item.connection = connection
        # Done
        return item
      rescue 
        raise AMEE::BadData.new("Couldn't load DataItemValue. Check that your URL is correct.")
      end

    end
  end
end