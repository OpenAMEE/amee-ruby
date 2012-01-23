# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  module Admin

    class ItemValueDefinitionList < AMEE::Collection
      # TODO this class does not yet page through multiple pages
      def initialize(connection,uid,options={})
        @uid=uid
        super(connection,options)
      end
      def klass
        ItemValueDefinition
      end
      def collectionpath
        "/definitions/itemDefinitions/#{@uid}/itemValueDefinitions"
      end

      def jsoncollector
        @doc['itemValueDefinitions']
      end
      def xmlcollectorpath
        '/Resources/ItemValueDefinitionsResource/ItemValueDefinitions/ItemValueDefinition'
      end

      def parse_json(p)
        data = {}
        data[:itemdefuid] = @uid
        data[:uid] = p['uid']
        data[:name] = p['name']
        data[:path] = p['path']
        data[:unit] = p['unit']
        data[:perunit] = p['perunit']
        data[:valuetype] = p['valueDefinition']['valueType']
        data[:drill]=p['drillDown']
        data[:from_profile]=p['fromProfile']
        data[:from_data]=p['fromData']
        data
      end
      def parse_xml(p)
        data = {}
        data[:itemdefuid] = @uid
        data[:uid] = x '@uid',:doc => p
        data[:name] = x 'Name',:doc => p  || data[:uid]
        data[:path] = x 'Path',:doc => p
        data[:unit] = x 'Unit',:doc => p
        data[:perunit] = x 'PerUnit',:doc => p
        data[:valuetype] =x 'ValueDefinition/ValueType',:doc => p
        data[:drill]=(x('DrillDown',:doc => p)=='true')
        data[:from_profile]=(x('FromProfile',:doc => p)=='true')
        data[:from_data]=(x('FromData',:doc => p)=='true')
        data
      end
    end

    class ItemValueDefinition < AMEE::Object

      def initialize(data = {})
        @itemdefuid=data[:itemdefuid]
        @name = data[:name]
        @uid = data[:uid]
        @path = data[:path]
        @unit = data[:unit]
        @perunit = data[:perunit]
        @valuetype = data[:valuetype]
        @default = data[:default] == "" ? nil : data[:default]
        @choices = data[:choices] || []
        @versions = data[:versions] || []
        @drill = data[:drill]
        @from_data = @drill ? false : data[:from_data] # Drills are also data, but we don't want them to show as such for clarity
        @from_profile = data[:from_profile]
        super
      end

      attr_reader :name,:uid,:path,:itemdefuid, :type, :valuetype, :unit, :perunit, :default, :choices, :versions

      # This function has bee deprecated in favour of the separate profile? data? and drill? functions
      def type
        raise AMEE::Deprecated
      end

      def profile?
        @from_profile
      end

      def data?
        @from_data
      end

      def drill?
        @drill
      end

      def self.list(connection)
        ItemValueDefinitionList.new(connection)
      end

      def self.parse(connection, response, is_list = true)
        # Parse data from response
        if response.is_json?
          item_definition = ItemValueDefinition.from_json(response)
        else
          item_definition = ItemValueDefinition.from_xml(response, is_list)
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
        p=doc['itemValueDefinition']
        data[:uid] = p['uid']
        data[:itemdefuid] = p['itemDefinition']['uid']
        data[:created] = DateTime.parse(p['created'])
        data[:modified] = DateTime.parse(p['modified'])
        data[:name] = p['name']
        data[:path] = p['path']
        data[:unit] = p['unit']
        data[:perunit] = p['perUnit']
        data[:valuetype] = p['valueDefinition']['valueType']
        data[:default] = p['value']
        data[:choices] = p['choices'].split(',')
        data[:versions] = p['apiVersions'].map{|v| v['apiVersion']}
        data[:drill]=p['drillDown']
        data[:from_profile]=p['fromProfile']
        data[:from_data]=p['fromData']
        # Create object
        ItemValueDefinition.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ItemValueDefinition from JSON. Check that your URL is correct.\n#{json}")
      end

      def self.from_xml(xml, is_list = true)
        prefix = is_list ? "/Resources/ItemValueDefinitionsResource/" : "/Resources/ItemValueDefinitionResource/"
        # Parse data from response into hash
        @doc = load_xml_doc(xml)
        data = {}
        data[:uid] = x(prefix + "ItemValueDefinition/@uid")
        data[:itemdefuid] = x(prefix + "ItemValueDefinition/ItemDefinition/@uid")
        data[:created] = DateTime.parse(x(prefix + "ItemValueDefinition/@created"))
        data[:modified] = DateTime.parse(x(prefix + "ItemValueDefinition/@modified"))
        data[:name] = x(prefix + "ItemValueDefinition/Name")
        data[:path] = x(prefix + "ItemValueDefinition/Path")
        data[:unit] = x(prefix + "ItemValueDefinition/Unit")
        data[:perunit] = x(prefix + "ItemValueDefinition/PerUnit")
        data[:valuetype] = x(prefix + "ItemValueDefinition/ValueDefinition/ValueType")
        data[:default] = x(prefix + "ItemValueDefinition/Value")
        data[:choices] = x(prefix + "ItemValueDefinition/Choices").split(',') rescue nil
        data[:versions] = @doc.xpath(prefix + "ItemValueDefinition/APIVersions/APIVersion/text()").map{|x| x.to_s}
        data[:drill]=(x(prefix + 'ItemValueDefinition/DrillDown')=='true')
        data[:from_profile]=(x(prefix + 'ItemValueDefinition/FromProfile')=='true')
        data[:from_data]=(x(prefix + 'ItemValueDefinition/FromData')=='true')
        # Create object
        ItemValueDefinition.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ItemValueDefinition from XML. Check that your URL is correct.\n#{xml}")
      end

      def self.get(connection, path, options = {})
        # Load data from path
        response = connection.get(path, options).body
        # Parse response
        item_definition = ItemValueDefinition.parse(connection, response, false)
        # Done
        return item_definition
      rescue
        raise AMEE::BadData.new("Couldn't load ItemValueDefinition. Check that your URL is correct.\n#{response}")
      end

 

      def self.load(connection,itemdefuid,ivduid,options={})
        ItemValueDefinition.get(connection,"/definitions/itemDefinitions/#{itemdefuid}/itemValueDefinitions/#{ivduid}",options)
      end

      def reload(connection)
        ItemValueDefinition.load(connection,itemdefuid,uid)
      end

      def self.update(connection, path, options = {})
        raise AMEE::NotSupported
        #        # Do we want to automatically fetch the item afterwards?
        #        get_item = options.delete(:get_item)
        #        get_item = true if get_item.nil?
        #        # Go
        #        response = connection.put(path, options)
        #        if get_item
        #          if response.body.empty?
        #            return ItemValueDefinition.get(connection, path)
        #          else
        #            return ItemValueDefinition.parse(connection, response.body)
        #          end
        #        end
        #      rescue
        #        raise AMEE::BadData.new("Couldn't update ItemValueDefinition. Check that your information is correct.\n#{response}")
      end

      def self.create(connection,itemdefuid, options = {})
        raise AMEE::NotSupported
        #        unless options.is_a?(Hash)
        #          raise AMEE::ArgumentError.new("Second argument must be a hash of options!")
        #        end
        #        # Send data
        #        response = connection.post("/definitions/itemDefinitions/#{itemdefuid}/itemValueDefintions", options).body
        #        # Parse response
        #        item_value_definition = ItemValueDefinition.parse(connection, response)
        #        # Get the ItemValueDefinition again
        #        return ItemValueDefinition.load(connection,itemdefuid , item_value_definition.uid)
        #      rescue
        #        raise AMEE::BadData.new("Couldn't create ItemValueDefinition. Check that your information is correct.\n#{response}")
      end

      def self.delete(connection, itemdefuid,item_value_definition)
        raise AMEE::NotSupported
        #        # Deleting takes a while... up the timeout to 120 seconds temporarily
        #        t = connection.timeout
        #        connection.timeout = 120
        #        connection.delete("/definitions/itemDefinitions/#{itemdefuid}/itemValueDefinitions/" + item_value_definition.uid)
        #        connection.timeout = t
        #      rescue
        #        raise AMEE::BadData.new("Couldn't delete ItemValueDefinition. Check that your information is correct.")
      end

      def full_path
        "/definitions/itemDefinitions/#{itemdefuid}/itemValueDefinitions/#{uid}"
      end

    end

  end

end
