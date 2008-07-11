module AMEE
  module Data
    class ItemValue < AMEE::Object

      def initialize(data = {})
        @value = data ? data[:value] : nil
        super
      end

      attr_reader :value
      
      def self.get(connection, path)
        # Load data from path
        response = connection.get(path)
        # Parse data from response into hash
        doc = REXML::Document.new(response)
        data = {}
        data[:uid] = REXML::XPath.first(doc, "/Resources/DataItemValueResource/ItemValue/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemValueResource/ItemValue/@Created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemValueResource/ItemValue/@Modified").to_s)
        data[:name] = REXML::XPath.first(doc, '/Resources/DataItemValueResource/ItemValue/Name').text
        data[:path] = path
        data[:value] = REXML::XPath.first(doc, '/Resources/DataItemValueResource/ItemValue/Value').text
        # Create item object
        item = ItemValue.new(data)
        # Store connection in object for future use
        item.connection = connection
        # Done
        return item
      end

    end
  end
end