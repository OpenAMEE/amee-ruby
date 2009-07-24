require 'date'

module AMEE
  module Data
    class Category < AMEE::Data::Object

      def initialize(data = {})
        @children = data ? data[:children] : []
        @items = data ? data[:items] : []
        super
      end

      attr_reader :children
      attr_reader :items

      def self.from_json(json)
        # Parse json
        doc = JSON.parse(json)
        data = {}
        data[:uid] = doc['dataCategory']['uid']
        data[:created] = DateTime.parse(doc['dataCategory']['created'])
        data[:modified] = DateTime.parse(doc['dataCategory']['modified'])
        data[:name] = doc['dataCategory']['name']
        data[:path] = doc['path']
        data[:children] = []
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
      rescue
        raise AMEE::BadData.new("Couldn't load DataCategory from JSON data. Check that your URL is correct.\n#{json}")
      end
      
      def self.from_xml(xml)
        # Parse XML
        doc = REXML::Document.new(xml)
        data = {}
        data[:uid] = REXML::XPath.first(doc, "/Resources/DataCategoryResource/DataCategory/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataCategoryResource/DataCategory/@created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataCategoryResource/DataCategory/@modified").to_s)
        data[:name] = REXML::XPath.first(doc, '/Resources/DataCategoryResource/DataCategory/?ame').text
        data[:path] = REXML::XPath.first(doc, '/Resources/DataCategoryResource//?ath').text || ""
        data[:children] = []
        REXML::XPath.each(doc, '/Resources/DataCategoryResource//Children/DataCategories/DataCategory') do |child|
          category_data = {}
          category_data[:name] = (child.elements['Name'] || child.elements['name']).text
          category_data[:path] = (child.elements['Path'] || child.elements['path']).text
          category_data[:uid] = child.attributes['uid'].to_s
          data[:children] << category_data
        end
        data[:items] = []
        REXML::XPath.each(doc, '/Resources/DataCategoryResource//Children/DataItems/DataItem') do |item|
          item_data = {}
          item_data[:uid] = item.attributes['uid'].to_s
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
      rescue
        raise AMEE::BadData.new("Couldn't load DataCategory from XML data. Check that your URL is correct.\n#{xml}")
      end
      
      def self.get(connection, path, items_per_page = 10)
        # Load data from path
        response = connection.get(path, :itemsPerPage => items_per_page).body
        # Parse data from response
        if response.is_json?
          cat = Category.from_json(response)
        else
          cat = Category.from_xml(response)
        end
        # Store connection in object for future use
        cat.connection = connection
        # Done
        return cat
      rescue
        raise AMEE::BadData.new("Couldn't load DataCategory. Check that your URL is correct.\n#{response}")
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

    end
  end
end
