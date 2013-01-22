# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  Epoch=DateTime.parse(Time.at(0).xmlschema).utc
  module Data
    class ItemValue < AMEE::Data::Object

      def initialize(data = {})
        @value = data ? data[:value] : nil
        @type = data ? data[:type] : nil
        @from_profile = data ? data[:from_profile] : nil
        @from_data = data ? data[:from_data] : nil
        @start_date = data ? data[:start_date] : nil
        super
      end

      attr_reader :type

      def value
        case type
        when "DECIMAL", "DOUBLE"
          @value.to_f
        else
          @value
        end
      end

      def value=(val)
        @value = val
      end

      def from_profile?
        @from_profile
      end

      def from_data?
        @from_data
      end

      attr_accessor :start_date
      attr_accessor :uid

      def uid_path
        # create a path which is safe for DIVHs by using the UID if one is avai
        if uid
          @path.split(/\//)[0..-2].push(uid).join('/')
        else
          @path
        end
      end

      def full_uid_path
        "/data#{uid_path}"
      end

      def self.from_json(json, path)
        # Read JSON
        doc = json.is_a?(String) ? JSON.parse(json)['itemValue'] : json
        data = {}
        data[:uid] = doc['uid']
        data[:created] = DateTime.parse(doc['created']) rescue nil
        data[:modified] = DateTime.parse(doc['modified']) rescue nil
        data[:name] = doc['name']
        data[:path] = path.gsub(/^\/data/, '')
        data[:value] = doc['value']
        data[:type] = doc['itemValueDefinition']['valueDefinition']['valueType']
        data[:start_date] = DateTime.parse(doc['startDate']) rescue nil
        # Create object
        ItemValue.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DataItemValue from JSON. Check that your URL is correct.\n#{json}")
      end

      def self.xmlpathpreamble
        "descendant-or-self::ItemValue/"
      end

      def self.from_xml(xml, path)
        # Read XML
        @doc = xml.is_a?(String) ? load_xml_doc(xml) : xml
        data = {}
        if @doc.xpath("descendant-or-self::ItemValue").length>1
          raise AMEE::BadData.new("Couldn't load DataItemValue from XML. This is an item value history.\n#{xml}")
        end
        raise if @doc.xpath("descendant-or-self::ItemValue").length==0
        begin
          data[:uid] = x "@uid"
          data[:created] = DateTime.parse(x "@Created") rescue nil
          data[:modified] = DateTime.parse(x "@Modified") rescue nil
          data[:name] = x 'Name'
          data[:path] = path.gsub(/^\/data/, '')
          data[:value] = x 'Value'
          data[:type] = x 'ItemValueDefinition/ValueDefinition/ValueType'
          data[:from_profile] =  false
          data[:from_data] = true
          data[:start_date] = DateTime.parse(x "StartDate") rescue nil
          # Create object
          ItemValue.new(data)
        rescue
          raise AMEE::BadData.new("Couldn't load DataItemValue from XML. Check that your URL is correct.\n#{xml}")
        end
      end

      def self.get(connection, path)
        # Load data from path
        response = connection.get(path).body
        # Parse data from response
        data = {}
        value = ItemValue.parse(connection, response, path)
        # Done
        return value
      rescue
        raise AMEE::BadData.new("Couldn't load DataItemValue. Check that your URL is correct.")
      end

      def save!
        if start_date
          ItemValue.update(connection,full_uid_path,:value=>value,
            :start_date=>start_date,:get_item=>false)
        else
          ItemValue.update(connection,full_uid_path,:value=>value,:get_item=>false)
        end
      end

      def delete!
        raise AMEE::BadData.new("Cannot delete initial value for time series") if start_date==AMEE::Epoch
        ItemValue.delete @connection,full_uid_path
      end

      def create!
        data_item_path=path.split(/\//)[0..-2].join('/')
        data_item=AMEE::Data::Item.new
        data_item.path=data_item_path
        data_item.connection=connection
        data_item.connection or raise "No connection to AMEE available"
        if start_date
          ItemValue.create(data_item,:start_date=>start_date,
            @path.split(/\//).pop.to_sym => value,:get_item=>false)
        else
          ItemValue.create(data_item,
            @path.split(/\//).pop.to_sym => value,:get_item=>false)
        end
      end

      def self.parse(connection, response, path)
        if response.is_json?
          value = ItemValue.from_json(response, path)
        else
          value = ItemValue.from_xml(response, path)
        end
        # Store connection in object for future use
        value.connection = connection
        # Done
        return value
      rescue
        raise AMEE::BadData.new("Couldn't load DataItemValue. Check that your URL is correct.\n#{response}")
      end

      def self.create(data_item, options = {})

        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
        # Store format if set
        format = options[:format]
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Third argument must be a hash of options!")
        end

        # Set startDate
        if (options[:start_date])
          options[:startDate] = options[:start_date].xmlschema
          options.delete(:start_date)
        end

        response = data_item.connection.post(data_item.full_path, options)
        location = response.headers_hash['Location'].match("https??://.*?(/.*)")[1]
        if get_item == true
          get_options = {}
          get_options[:format] = format if format
          return AMEE::Data::ItemValue.get(data_item.connection, location)
        else
          return location
        end
      rescue
        raise AMEE::BadData.new("Couldn't create DataItemValue. Check that your information is correct.")
      end

      def self.update(connection, path, options = {})
        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
        # Set startDate
        if (options[:start_date])
          options[:startDate] = options[:start_date].xmlschema if options[:start_date]!=Epoch
          options.delete(:start_date)
        end
        # Go
        response = connection.put(path, options)
        if get_item
          if response.body.empty?
            return AMEE::Data::ItemValue.get(connection, path)
          else
            return AMEE::Data::ItemValue.parse(connection, response.body)
          end
        end
      rescue
        raise AMEE::BadData.new("Couldn't update DataItemValue. Check that your information is correct.\n#{response}")
      end

      def update(options = {})
        AMEE::Data::ItemValue.update(connection, full_path, options)
      end


      def self.delete(connection, path)
        connection.delete(path)
        rescue
         raise AMEE::BadData.new("Couldn't delete DataItemValue. Check that your information is correct.")
      end

    end
  end
end
