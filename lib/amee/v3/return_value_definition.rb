# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  module Admin

    class ReturnValueDefinitionList < AMEE::Collection
      # TODO this class does not yet page through multiple pages
      def initialize(connection,uid,options={})
        @uid=uid
        @use_v3_connection=true
        super(connection,options)
      end
      def klass
        ReturnValueDefinition
      end
      def collectionpath
        "/#{AMEE::Connection.api_version}/definitions/#{@uid}/returnvalues;full"
      end

      def jsoncollector
        @doc['returnValueDefinitions']
      end
      def xmlcollectorpath
        '/Representation/ReturnValueDefinitions/ReturnValueDefinition'
      end

      def parse_json(p)
        data = {}
        data[:itemdefuid] = @uid
        data[:uid] = p['uid']
        data[:name] = p['type']
        data[:unit] = p['unit']
        data[:perunit] = p['perunit']
        data[:valuetype] = p['valueDefinition']['valueType']
        data
      end
      def parse_xml(p)
        data = {}
        data[:itemdefuid] = @uid
        data[:uid] = x '@uid',:doc => p
        data[:name] = x 'Type',:doc => p  || data[:uid]
        data[:unit] = x 'Unit',:doc => p
        data[:perunit] = x 'PerUnit',:doc => p
        data
      end
    end

    class ReturnValueDefinition < AMEE::Object

      def initialize(data = {})
        @itemdefuid=data[:itemdefuid]
        @name = data[:name]
        @uid = data[:uid]       
        @type = data[:type]
        @unit = data[:unit]
        @perunit = data[:perunit]
        @valuetype = data[:valuetype]
        
        super
      end

      attr_reader :name,:uid,:itemdefuid, :type, :valuetype, :unit, :perunit
     
      def self.list(connection)
        ReturnValueDefinitionList.new(connection)
      end

      def self.parse(connection, response)
        # Parse data from response
        if response.is_json?
          item_definition = ReturnValueDefinition.from_json(response)
        else
          item_definition = ReturnValueDefinition.from_xml(response)
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
        p=doc['returnValueDefinition']
        data[:uid] = p['uid']
        data[:itemdefuid] = p['itemDefinition']['uid']
        data[:type] = p['type']
        data[:path] = p['path']
        data[:unit] = p['unit']
        data[:perunit] = p['perUnit']
        data[:valuetype] = p['valueDefinition']['valueType']
        data[:default] = p['value']
        
        # Create object
        ReturnValueDefinition.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ReturnValueDefinition from JSON. Check that your URL is correct.\n#{json}")
      end

      def self.xmlpathpreamble
        "/Representation/ReturnValueDefinition/"
      end

      def self.from_xml(xml)
      
       
        # Parse data from response into hash
        doc = load_xml_doc(xml)
        data = {}
        data[:uid] = x "@uid",:doc=>doc
        data[:itemdefuid] = x "ItemDefinition/@uid",:doc=>doc
        data[:type] = x "Type",:doc=>doc
        data[:unit] = x "Unit",:doc=>doc
        data[:perunit] =  x "PerUnit",:doc=>doc
        data[:valuetype] = x  "ValueDefinition/ValueType",:doc=>doc
        data[:default] = x "ReturnValueDefinition/Default",:doc=>doc
        
       
        # Create object
        ReturnValueDefinition.new(data)
      rescue => err
        raise AMEE::BadData.new("Couldn't load ReturnValueDefinition from XML. Check that your URL is correct.\n#{xml}\n#{err}")
      end

      def self.get(connection, path, options = {})
        # Load data from path
        response = connection.v3_get(path, options)
        # Parse response
        item_definition = ReturnValueDefinition.parse(connection, response)
        # Done
        return item_definition
      rescue => err
        raise AMEE::BadData.new("Couldn't load ReturnValueDefinition. Check that your URL is correct.\n#{response}\n#{err}")
      end

 

      def self.load(connection,itemdefuid,ivduid,options={})
        ReturnValueDefinition.get(connection,"/#{AMEE::Connection.api_version}/definitions/#{itemdefuid}/returnvalues/#{ivduid};full",options)
      end

      def reload(connection)
        ReturnValueDefinition.load(connection,itemdefuid,uid)
      end

      def self.update(connection, path, options = {})
        
        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
        # Go
        response = connection.v3_put(path, options)
        if get_item
          if response.empty?
            return ReturnValueDefinition.get(connection, path)
          else
            return ReturnValueDefinition.parse(connection, response)
          end
        end
      rescue
        raise AMEE::BadData.new("Couldn't update ReturnValueDefinition. Check that your information is correct.\n#{response}")
      end

      def self.create(connection,itemdefuid, options = {})
        
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Second argument must be a hash of options!")
        end
        # Send data
        vt=options.delete(:valuetype)
        case vt
        when 'text'
          options.merge!( :valueDefinition=>"CCEB59CACE1B")
        else
          options.merge!( :valueDefinition=>"45433E48B39F")
        end
        
        options.merge!(:returnobj=>true)
        response = connection.v3_post("/#{AMEE::Connection.api_version}/definitions/#{itemdefuid}/returnvalues", options)
        return ReturnValueDefinition.load(connection,itemdefuid , response['Location'].split('/')[7])
      rescue
        raise AMEE::BadData.new("Couldn't create ReturnValueDefinition. Check that your information is correct.\n#{response}")
      end

      def self.delete(connection, itemdefuid,return_value_definition)
        
        # Deleting takes a while... up the timeout to 120 seconds temporarily
        t = connection.timeout
        connection.timeout = 120
        connection.v3_delete("/#{AMEE::Connection.api_version}/definitions/#{itemdefuid}/returnvalues/" + return_value_definition.uid)
        connection.timeout = t
      rescue
        raise AMEE::BadData.new("Couldn't delete ReturnValueDefinition. Check that your information is correct.")
      end

    end

  end

end
