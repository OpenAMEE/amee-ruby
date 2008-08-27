module AMEE
  module Data
    class Item < AMEE::DataObject

      def initialize(data = {})
        @values = data ? data[:values] : []
        @choices = data ? data[:choices] : []
        @label = data ? data[:label] : []
        super
      end

      attr_reader :values
      attr_reader :choices
      attr_reader :label

      def self.from_json(json)
        # Read JSON
        doc = JSON.parse(json)
        data = {}
        data[:uid] = doc['dataItem']['uid']
        data[:created] = DateTime.parse(doc['dataItem']['created'])
        data[:modified] = DateTime.parse(doc['dataItem']['modified'])
        data[:name] = doc['dataItem']['name']
        data[:path] = doc['path']
        data[:label] = doc['dataItem']['label']
        # Get values
        data[:values] = []
        doc['dataItem']['itemValues'].each do |value|
          value_data = {}
          value_data[:name] = value['name']
          value_data[:path] = value['path']
          value_data[:value] = value['value']
          value_data[:uid] = value['uid']
          data[:values] << value_data
        end
        # Get choices
        data[:choices] = []
        doc['userValueChoices']['choices'].each do |choice|
          choice_data = {}
          choice_data[:name] = choice['name']
          choice_data[:value] = choice['value']
          data[:choices] << choice_data
        end
        # Create object
        Item.new(data)
      rescue 
        raise AMEE::BadData.new("Couldn't load DataItem from JSON. Check that your URL is correct.")
      end
      
      def self.from_xml(xml)
        # Parse data from response into hash
        doc = REXML::Document.new(xml)
        data = {}
        data[:uid] = REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/@created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/@modified").to_s)
        data[:name] = REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/Name').text
        data[:path] = REXML::XPath.first(doc, '/Resources/DataItemResource/Path').text
        data[:label] = REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/Label').text
        # Get values
        data[:values] = []
        REXML::XPath.each(doc, '/Resources/DataItemResource/DataItem/ItemValues/ItemValue') do |value|
          value_data = {}
          value_data[:name] = value.elements['Name'].text
          value_data[:path] = value.elements['Path'].text
          value_data[:value] = value.elements['Value'].text
          value_data[:uid] = value.attributes['uid'].to_s
          data[:values] << value_data
        end
        # Get choices
        data[:choices] = []
        REXML::XPath.each(doc, '/Resources/DataItemResource/Choices/Choices/Choice') do |choice|
          choice_data = {}
          choice_data[:name] = choice.elements['Name'].text
          choice_data[:value] = choice.elements['Value'].text || ""
          data[:choices] << choice_data
        end
        # Create object
        Item.new(data)
      rescue 
        raise AMEE::BadData.new("Couldn't load DataItem from XML. Check that your URL is correct.")
      end

      
      def self.get(connection, path)
        # Load data from path
        response = connection.get(path)
        # Parse data from response
        if response.is_json?
          item = Item.from_json(response)
        else
          item = Item.from_xml(response)
        end
        # Store connection in object for future use
        item.connection = connection
        # Done
        return item
      rescue
        raise AMEE::BadData.new("Couldn't load DataItem. Check that your URL is correct.")
      end

    end
  end
end
