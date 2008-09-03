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
            item_data[:label] = item['label']
            item_data[:path] = item['path']
            item_data[:uid] = item['uid']
            data[:items] << item_data
          end
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DataCategory from JSON data. Check that your URL is correct.")
      end
      
      def self.from_xml(xml)
        # Parse XML
        doc = REXML::Document.new(xml)
        data = {}
        data[:uid] = REXML::XPath.first(doc, "/Resources/DataCategoryResource/DataCategory/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataCategoryResource/DataCategory/@created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataCategoryResource/DataCategory/@modified").to_s)
        data[:name] = REXML::XPath.first(doc, '/Resources/DataCategoryResource/DataCategory/Name').text
        data[:path] = REXML::XPath.first(doc, '/Resources/DataCategoryResource/Path').text || ""
        data[:children] = []
        REXML::XPath.each(doc, '/Resources/DataCategoryResource/Children/DataCategories/DataCategory') do |child|
          category_data = {}
          category_data[:name] = child.elements['Name'].text
          category_data[:path] = child.elements['Path'].text
          category_data[:uid] = child.attributes['uid'].to_s
          data[:children] << category_data
        end
        data[:items] = []
        REXML::XPath.each(doc, '/Resources/DataCategoryResource/Children/DataItems/DataItem') do |item|
          item_data = {}
          item_data[:label] = item.elements['label'].text
          item_data[:path] = item.elements['path'].text
          item_data[:uid] = item.attributes['uid'].to_s
          data[:items] << item_data
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DataCategory from XML data. Check that your URL is correct.")
      end
      
      def self.get(connection, path)
        # Load data from path
        response = connection.get(path)
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
        raise AMEE::BadData.new("Couldn't load DataCategory. Check that your URL is correct.")
      end
      
      def self.root(connection)
        self.get(connection, '/data')
      end
      
      def child(child_path)
        AMEE::Data::Category.get(connection, "#{full_path}/#{child_path}")
      end
      
    end
  end
end