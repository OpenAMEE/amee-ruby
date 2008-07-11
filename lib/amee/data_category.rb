require 'date'

module AMEE
  module Data
    class Category < AMEE::Object

      def initialize(data = {})
        @children = data ? data[:children] : []
        @items = data ? data[:items] : []
        super
      end

      attr_reader :children
      attr_reader :items

      def self.get(connection, path)
        # Load data from path
        response = connection.get(path)
        # Parse data from response into hash
        doc = REXML::Document.new(response)
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
        # Create category object
        cat = Category.new(data)
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