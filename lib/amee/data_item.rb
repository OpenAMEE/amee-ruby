module AMEE
  module Data
    class Item < AMEE::Object

      def initialize(data = {})
        @values = data ? data[:values] : []
        @label = data ? data[:label] : []
        super
      end

      attr_reader :values
      attr_reader :label

      def self.get(connection, path)
        # Load data from path
        response = connection.get(path)
        # Parse data from response into hash
        doc = REXML::Document.new(response)
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
        # Create item object
        item = Item.new(data)
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