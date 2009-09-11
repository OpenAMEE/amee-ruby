module AMEE
  module Admin

    class ItemDefinitionList < Array

      def initialize(connection, options = {})
        # Load data from path
        response = connection.get('/definitions/itemDefinitions', options).body
        # Parse data from response
        if response.is_json?
          # Read JSON
          doc = JSON.parse(response)
          @pager = AMEE::Pager.from_json(doc['pager'])
          doc['itemDefinitions'].each do |p|
            data = {}
            data[:uid] = p['uid']
            data[:name] = p['name']
            # Create ItemDefinition
            item_definition = ItemDefinition.new(data)
            # Store in array
            self << item_definition
          end
        else
          # Read XML
          doc = REXML::Document.new(response)
          @pager = AMEE::Pager.from_xml(REXML::XPath.first(doc, '/Resources/ItemDefinitionsResource/Pager'))
          REXML::XPath.each(doc, '/Resources/ItemDefinitionsResource/ItemDefinitions/ItemDefinition') do |p|
            data = {}
            data[:uid] = p.attributes['uid'].to_s
            data[:name] = p.elements['Name'].text || data[:uid]
            # Create ItemDefinition
            item_definition = ItemDefinition.new(data)
            # Store connection in ItemDefinition object
            item_definition.connection = connection
            # Store in array
            self << item_definition
          end
        end
      rescue
        raise AMEE::BadData.new("Couldn't load ItemDefinition list.\n#{response}")
      end

      attr_reader :pager

    end

    class ItemDefinition < AMEE::Object

      def initialize(data = {})
        @name = data[:name]
        super
      end

      attr_reader :name

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
