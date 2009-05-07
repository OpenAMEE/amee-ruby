module AMEE
  module Admin
    class ItemDefinition < AMEE::Object

      def initialize(data = {})
        @name = data[:name]
        super
      end

      attr_reader :name

      def self.from_json(json)
        # Read JSON
        doc = JSON.parse(json)
        data = {}
        data[:uid] = doc['itemDefinition']['uid']
        data[:created] = DateTime.parse(doc['itemDefinition']['created'])
        data[:modified] = DateTime.parse(doc['itemDefinition']['modified'])
        data[:name] = doc['itemDefinition']['name']
        # Create object
        ItemDefinition.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ItemDefinition from JSON. Check that your URL is correct.")
      end
      
      def self.from_xml(xml)
        # Parse data from response into hash
        doc = REXML::Document.new(xml)
        data = {}
        data[:uid] = REXML::XPath.first(doc, "/Resources/ItemDefinitionResource/ItemDefinition/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, "/Resources/ItemDefinitionResource/ItemDefinition/@created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/Resources/ItemDefinitionResource/ItemDefinition/@modified").to_s)
        data[:name] = REXML::XPath.first(doc, '/Resources/ItemDefinitionResource/ItemDefinition/Name').text
        # Create object
        ItemDefinition.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ItemDefinition from XML. Check that your URL is correct.")
      end

      def self.get(connection, path, options = {})
        # Load data from path
        response = connection.get(path, options).body
        # Parse data from response
        if response.is_json?
          item_definition = ItemDefinition.from_json(response)
        else
          item_definition = ItemDefinition.from_xml(response)
        end
        # Store connection in object for future use
        item_definition.connection = connection
        # Done
        return item_definition
      rescue
        raise AMEE::BadData.new("Couldn't load ItemDefinition. Check that your URL is correct.")
      end

      def update(options = {})
        response = connection.put(full_path, options).body
      rescue
        raise AMEE::BadData.new("Couldn't update ItemDefinition. Check that your information is correct.")
      end

    end
  end
end
