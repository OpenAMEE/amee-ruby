module AMEE
  module Data
    class Item < AMEE::Data::Object

      def initialize(data = {})
        @values = data[:values]
        @choices = data[:choices]
        @label = data[:label]
        @item_definition = data[:item_definition]
        @total_amount = data[:total_amount]
        super
      end

      attr_reader :values
      attr_reader :choices
      attr_reader :label
      attr_reader :item_definition
      attr_reader :total_amount

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
        data[:item_definition] = doc['dataItem']['itemDefinition']['uid']
        data[:total_amount] = doc['amountPerMonth'] rescue nil
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
        data[:name] = (REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/Name') || REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/name')).text
        data[:path] = (REXML::XPath.first(doc, '/Resources/DataItemResource/Path') || REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/path')).text
        data[:label] = (REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/Label') || REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/label')).text
        data[:item_definition] = REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/ItemDefinition/@uid').to_s
        data[:total_amount] = REXML::XPath.first(doc, '/Resources/DataItemResource/AmountPerMonth').text.to_f rescue nil
        # Get values
        data[:values] = []
        REXML::XPath.each(doc, '/Resources/DataItemResource/DataItem/ItemValues/ItemValue') do |value|
          value_data = {}
          value_data[:name] = (value.elements['Name'] || value.elements['name']).text
          value_data[:path] = (value.elements['Path'] || value.elements['path']).text
          value_data[:value] = (value.elements['Value'] || value.elements['value']).text
          value_data[:uid] = value.attributes['uid'].to_s
          data[:values] << value_data
        end
        # Get choices
        data[:choices] = []
        REXML::XPath.each(doc, '/Resources/DataItemResource/Choices/Choices/Choice') do |choice|
          choice_data = {}
          choice_data[:name] = (choice.elements['Name']).text
          choice_data[:value] = (choice.elements['Value']).text || ""
          data[:choices] << choice_data
        end
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DataItem from XML. Check that your URL is correct.")
      end

      
      def self.get(connection, path, options = {})
        # Load data from path
        response = connection.get(path, options).body
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

      def update(options = {})
        response = connection.put(full_path, options).body
      rescue
        raise AMEE::BadData.new("Couldn't update DataItem. Check that your information is correct.")
      end

      def value(name_or_path_or_uid)
        val = values.find{ |x| x[:name] == name_or_path_or_uid || x[:path] == name_or_path_or_uid || x[:uid] == name_or_path_or_uid}
        val ? val[:value] : nil
      end

    end
  end
end
