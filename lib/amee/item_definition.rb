module AMEE
  module Admin

    class ItemDefinitionList < AMEE::Collection
      def collectionpath
        '/definitions/itemDefinitions'
      end
      def klass
        ItemDefinition
      end
      def jsoncollector
        @doc['itemDefinitions']
      end
      def xmlcollectorpath
        '/Resources/ItemDefinitionsResource/ItemDefinitions/ItemDefinition'
      end

      def parse_json(p)
        data = {}
        data[:uid] = p['uid']
        data[:name] = p['name']
        data
      end
      def parse_xml(p)
        data = {}
        data[:uid] = x '@uid',:doc=>p
        data[:name] = x('Name',:doc=>p) || data[:uid]
        data
      end
    end

    class ItemDefinition < AMEE::Object

      def initialize(data = {})
        @name = data[:name]
        @drill_downs = data[:drillDown] || []
        super
      end

      attr_reader :name, :drill_downs

      def self.list(connection)
        ItemDefinitionList.new(connection)
      end

      def self.parse(connection, response, is_list = true)
        # Parse data from response
        if response.is_json?
          item_definition = ItemDefinition.from_json(response)
        else
          item_definition = ItemDefinition.from_xml(response, is_list)
        end
        # Store connection in object for future use
        item_definition.connection = connection
        # Done
        return item_definition
      end

      def self.from_json(json)
        # Read JSON
        doc = JSON.parse(json)
        data = {}
        data[:uid] = doc['itemDefinition']['uid']
        data[:created] = DateTime.parse(doc['itemDefinition']['created'])
        data[:modified] = DateTime.parse(doc['itemDefinition']['modified'])
        data[:name] = doc['itemDefinition']['name']
        data[:drillDown] = doc['itemDefinition']['drillDown'].split(",") rescue nil
        # Create object
        ItemDefinition.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ItemDefinition from JSON. Check that your URL is correct.\n#{json}")
      end

      def self.from_xml(xml, is_list = true)
        prefix = is_list ? "/Resources/ItemDefinitionsResource/" : "/Resources/ItemDefinitionResource/"
        # Parse data from response into hash
        doc = REXML::Document.new(xml)
        data = {}
        data[:uid] = REXML::XPath.first(doc, prefix + "ItemDefinition/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, prefix + "ItemDefinition/@created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, prefix + "ItemDefinition/@modified").to_s)
        data[:name] = REXML::XPath.first(doc, prefix + "ItemDefinition/Name").text
        data[:drillDown] = REXML::XPath.first(doc, prefix + "ItemDefinition/DrillDown").text.split(",") rescue nil
        # Create object
        ItemDefinition.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ItemDefinition from XML. Check that your URL is correct.\n#{xml}")
      end

      def self.get(connection, path, options = {})
        # Load data from path
        response = connection.get(path, options).body
        # Parse response
        item_definition = ItemDefinition.parse(connection, response, false)
        # Done
        return item_definition
      rescue
        raise AMEE::BadData.new("Couldn't load ItemDefinition. Check that your URL is correct.\n#{response}")
      end

      def self.update(connection, path, options = {})
        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
        # Go
        response = connection.put(path, options)
        if get_item
          if response.body.empty?
            return ItemDefinition.get(connection, path)
          else
            return ItemDefinition.parse(connection, response.body)
          end
        end
      rescue
        raise AMEE::BadData.new("Couldn't update ItemDefinition. Check that your information is correct.\n#{response}")
      end

      def self.load(connection,uid,options={})
        ItemDefinition.get(connection,"/definitions/itemDefinitions/#{uid}",options)
      end

      def item_value_definition_list
        @item_value_definitions ||= AMEE::Admin::ItemValueDefinitionList.new(connection,uid)
      end

      def self.create(connection, options = {})
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Second argument must be a hash of options!")
        end
        # Send data
        response = connection.post("/definitions/itemDefinitions", options).body
        # Parse response
        item_definition = ItemDefinition.parse(connection, response)
        # Get the ItemDefinition again
        return ItemDefinition.get(connection, "/definitions/itemDefinitions/" + item_definition.uid)
      rescue
        raise AMEE::BadData.new("Couldn't create ItemDefinition. Check that your information is correct.\n#{response}")
      end

      def self.delete(connection, item_definition)
        # Deleting takes a while... up the timeout to 120 seconds temporarily
        t = connection.timeout
        connection.timeout = 120
        connection.delete("/definitions/itemDefinitions/" + item_definition.uid)
        connection.timeout = t
      rescue
        raise AMEE::BadData.new("Couldn't delete ProfileItem. Check that your information is correct.")
      end

    end
  end
end
