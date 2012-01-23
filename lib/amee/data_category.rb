# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'date'

module AMEE
  module Data
    class Category < AMEE::Data::Object

      def initialize(data = {})
        @children = data ? data[:children] : []
        @items = data ? data[:items] : []
        @pager = data ? data[:pager] : nil
        @itemdef = data ? data[:itemdef] : nil
        super
      end

      attr_reader :children
      attr_reader :items
      attr_reader :pager
      attr_reader :itemdef

      def item_definition
        return nil unless itemdef
        @item_definition ||= AMEE::Admin::ItemDefinition.load(connection,itemdef)
      end

      def self.from_json(json)
        # Parse json
        doc = JSON.parse(json)
        begin
          data = {}
          data[:uid] = doc['dataCategory']['uid']
          data[:created] = DateTime.parse(doc['dataCategory']['created'])
          data[:modified] = DateTime.parse(doc['dataCategory']['modified'])
          data[:name] = doc['dataCategory']['name']
          data[:path] = doc['path']
          data[:children] = []
          data[:pager] = AMEE::Pager.from_json(doc['children']['pager'])
          itemdef=doc['dataCategory']['itemDefinition']
          data[:itemdef] = itemdef ? itemdef['uid'] : nil
          doc['children']['dataCategories'].each do |child|
            category_data = {}
            category_data[:name] = child['name']
            category_data[:path] = child['path']
            category_data[:uid] = child['uid']
            data[:children] << category_data
          end
          data[:items] = []
          if doc['children']['dataItems']['rows']
            doc['children']['dataItems']['rows'].each do |item|
              item_data = {}
              item.each_pair do |key, value|
                item_data[key.to_sym] = value
              end
              data[:items] << item_data
            end
          end
          # Create object
          Category.new(data)
        rescue AMEE::JSONParseError
          raise AMEE::BadData.new("Couldn't load DataCategory from JSON data. Check that your URL is correct.\n#{json}")
        end
      end

      def self.from_xml(xml)
        # Parse XML
        @doc = load_xml_doc(xml)
        begin
          data = {}
          data[:uid] = x '/Resources/DataCategoryResource/DataCategory/@uid'
          data[:created] = DateTime.parse(x("/Resources/DataCategoryResource/DataCategory/@created"))
          data[:modified] = DateTime.parse(x("/Resources/DataCategoryResource/DataCategory/@modified"))
          data[:name] = x('/Resources/DataCategoryResource/DataCategory/Name') || x('/Resources/DataCategoryResource/DataCategory/name')
          data[:path] = x('/Resources/DataCategoryResource/Path') || x('/Resources/DataCategoryResource/DataCategory/path') || ""
          data[:pager] = AMEE::Pager.from_xml(@doc.xpath('//Pager').first)
          itemdefattrib=x('/Resources/DataCategoryResource//ItemDefinition/@uid')
          data[:itemdef] = itemdefattrib ? itemdefattrib.to_s : nil
          data[:children] = []
          @doc.xpath('/Resources/DataCategoryResource//Children/DataCategories/DataCategory').each do |child|
            category_data = {}
            category_data[:name] = x('Name', :doc => child) || x('name', :doc => child)
            category_data[:path] = x('Path', :doc => child) || x('path', :doc => child)
            category_data[:uid] = x('@uid', :doc => child)
            data[:children] << category_data
          end
          data[:items] = []
          @doc.xpath('/Resources/DataCategoryResource//Children/DataItems/DataItem').each do |item|
            item_data = {}
            item_data[:uid] = x('@uid', :doc => item)
            item.elements.each do |element|
              item_data[element.name.to_sym] = element.text
            end
            if item_data[:path].nil?
              item_data[:path] = item_data[:uid]
            end
            data[:items] << item_data
          end
          # Create object
          Category.new(data)
        rescue AMEE::XMLParseError, TypeError
          raise AMEE::BadData.new("Couldn't load DataCategory from XML data. Check that your URL is correct.\n#{xml}")
        end
      end

      def self.get(connection, path, orig_options = {})
        unless orig_options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Third argument must be a hash of options!")
        end
        # Convert to AMEE options
        options = orig_options.clone
        if orig_options[:items_per_page]
          options[:itemsPerPage] = orig_options[:items_per_page]
        else
          options[:itemsPerPage] = 10
        end

        # Load data from path
        cat = get_and_parse(connection, path, options)

        # Store connection in object for future use
        cat.connection = connection
        # Done
        return cat
      end

      def self.root(connection)
        self.get(connection, '/data')
      end

      def child(child_path)
        AMEE::Data::Category.get(connection, "#{full_path}/#{child_path}")
      end

      def drill
        AMEE::Data::DrillDown.get(connection, "#{full_path}/drill")
      end

      def item(options)
        # Search fields - from most specific to least specific
        item = items.find{ |x| (x[:uid] && x[:uid] == options[:uid]) ||
                               (x[:name] && x[:name] == options[:name]) ||
                               (x[:path] && x[:path] == options[:path]) ||
                               (x[:label] && x[:label] == options[:label]) }
        # Pass through some options
        new_opts = {}
        new_opts[:format] = options[:format] if options[:format]
        item ? AMEE::Data::Item.get(connection, "#{full_path}/#{item[:path]}", new_opts) : nil
      end

      def self.create(category, options = {})

        connection = category.connection
        path = category.full_path

        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)

        get_item = true if get_item.nil?
        # Store format if set
        format = options[:format]
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Third argument must be a hash of options!")
        end
        # Send data to path
        options[:newObjectType] = "DC"
        response = connection.post(path, options)
        if response.headers_hash.has_key?('Location') && response.headers_hash['Location']
          location = response.headers_hash['Location'].match("https??://.*?(/.*)")[1]
        else
          category = Category.parse(connection, response.body)
          location = category.full_path
        end
        if get_item == true
          get_options = {}
          get_options[:format] = format if format
          return AMEE::Data::Category.get(connection, location, get_options)
        else
          return location
        end
      rescue
        raise AMEE::BadData.new("Couldn't create DataCategory. Check that your information is correct.\n#{response}")
      end

     def self.delete(connection, path)
       connection.delete(path)
     rescue
       raise AMEE::BadData.new("Couldn't delete DataCategory. Check that your information is correct.")
     end

     def self.update(connection, path, options = {})
       # Do we want to automatically fetch the item afterwards?
       get_item = options.delete(:get_item)
       get_item = true if get_item.nil?
       # Go
       response = connection.put(path, options)
       if get_item
         if response.body.empty?
           return Category.get(connection, path)
         else
           return Category.parse(connection, response.body)
         end
       end
     rescue
       raise AMEE::BadData.new("Couldn't update Data Category. Check that your information is correct.")
     end

    end
  end
end
