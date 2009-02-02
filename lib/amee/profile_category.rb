require 'date'

module AMEE
  module Profile
    class Category < AMEE::Profile::Object

      def initialize(data = {})
        @children = data ? data[:children] : []
        @items = data ? data[:items] : []
        @total_amount_per_month = data[:total_amount_per_month]
        super
      end

      attr_reader :children
      attr_reader :items
      attr_reader :total_amount_per_month

      def self.parse_json_profile_item(item)
        item_data = {}
        item_data[:values] = {}
        item.each_pair do |key, value|
          case key
            when 'dataItemLabel', 'dataItemUid', 'name', 'path', 'uid'
              item_data[key.to_sym] = value
            when 'created', 'modified', 'label' # ignore these
              nil
            when 'validFrom'
              item_data[:validFrom] = DateTime.strptime(value, "%Y%m%d")
            when 'end'
              item_data[:end] = (value == "true")
            when 'amountPerMonth'
              item_data[:amountPerMonth] = value.to_f
            else
              item_data[:values][key.to_sym] = value
          end
        end
        item_data[:path] ||= item_data[:uid] # Fill in path if not retrieved from response
        return item_data
      end

      def self.parse_json_profile_category(category)
        datacat = category['dataCategory'] ? category['dataCategory'] : category
        category_data = {}
        category_data[:name] = datacat['name']
        category_data[:path] = datacat['path']
        category_data[:uid] = datacat['uid']
        category_data[:totalAmountPerMonth] = category['totalAmountPerMonth'].to_f
        category_data[:children] = []
        category_data[:items] = []
        if category['children']
          category['children'].each do |child|
            if child[0] == 'dataCategories'
              child[1].each do |child_cat|
                category_data[:children] << parse_json_profile_category(child_cat)
              end
            end
            if child[0] == 'profileItems' && child[1]['rows']
              child[1]['rows'].each do |child_item|
                category_data[:items] << parse_json_profile_item(child_item)
              end
            end
          end
        end
        return category_data
      end

      def self.from_json(json)
        # Parse json
        doc = JSON.parse(json)
        data = {}
        data[:profile_uid] = doc['profile']['uid']
        data[:profile_date] = DateTime.strptime(doc['profileDate'], "%Y%m")
        data[:name] = doc['dataCategory']['name']
        data[:path] = doc['path']
        data[:total_amount_per_month] = doc['totalAmountPerMonth']
        data[:children] = []
        if doc['children'] && doc['children']['dataCategories']
          doc['children']['dataCategories'].each do |child|
            data[:children] << parse_json_profile_category(child)
          end
        end
        data[:items] = []
        profile_items = []
        profile_items.concat doc['children']['profileItems']['rows'] rescue nil
        profile_items << doc['profileItem'] unless doc['profileItem'].nil?
        profile_items.each do |item|
          data[:items] << parse_json_profile_item(item)
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory from JSON data. Check that your URL is correct.")
      end

      def self.parse_xml_profile_item(item)
        item_data = {}
        item_data[:values] = {}
        item.elements.each do |element|
          key = element.name
          value = element.text
          case key.downcase
            when 'dataitemlabel', 'dataitemuid', 'name', 'path'
              item_data[key.to_sym] = value
            when 'validfrom'
              item_data[:validFrom] = DateTime.strptime(value, "%Y%m%d")
            when 'end'
              item_data[:end] = (value == "true")
            when 'amountpermonth'
              item_data[:amountPerMonth] = value.to_f
            else
              item_data[:values][key.to_sym] = value
          end
        end
        item_data[:uid] = item.attributes['uid'].to_s
        item_data[:path] ||= item_data[:uid] # Fill in path if not retrieved from response
        return item_data
      end

      def self.parse_xml_profile_category(category)
        category_data = {}
        category_data[:name] = category.elements['DataCategory'].elements['Name'].text
        category_data[:path] = category.elements['DataCategory'].elements['Path'].text
        category_data[:uid] = category.elements['DataCategory'].attributes['uid'].to_s
        category_data[:totalAmountPerMonth] = category.elements['TotalAmountPerMonth'].text.to_f rescue nil
        category_data[:children] = []
        category_data[:items] = []
        if category.elements['Children']
          category.elements['Children'].each do |child|
            if child.name == 'ProfileCategories'
              child.each do |child_cat|
                category_data[:children] << parse_xml_profile_category(child_cat)
              end
            end
            if child.name == 'ProfileItems'
              child.each do |child_item|
                category_data[:items] << parse_xml_profile_item(child_item)
              end
            end
          end
        end
        return category_data
      end

      def self.from_xml(xml)
        # Parse XML
        doc = REXML::Document.new(xml)
        data = {}
        data[:profile_uid] = REXML::XPath.first(doc, "/Resources/ProfileCategoryResource/Profile/@uid").to_s
        data[:profile_date] = DateTime.strptime(REXML::XPath.first(doc, "/Resources/ProfileCategoryResource/ProfileDate").text, "%Y%m")
        data[:name] = REXML::XPath.first(doc, '/Resources/ProfileCategoryResource/DataCategory/Name').text
        data[:path] = REXML::XPath.first(doc, '/Resources/ProfileCategoryResource/Path').text || ""
        data[:total_amount_per_month] = REXML::XPath.first(doc, '/Resources/ProfileCategoryResource/TotalAmountPerMonth').text.to_f rescue nil
        data[:children] = []
        REXML::XPath.each(doc, '/Resources/ProfileCategoryResource/Children/ProfileCategories/DataCategory') do |child|
          category_data = {}
          category_data[:name] = child.elements['Name'].text
          category_data[:path] = child.elements['Path'].text
          category_data[:uid] = child.attributes['uid'].to_s
          data[:children] << category_data
        end
        REXML::XPath.each(doc, '/Resources/ProfileCategoryResource/Children/ProfileCategories/ProfileCategory') do |child|
          data[:children] << parse_xml_profile_category(child)
        end
        data[:items] = []
        REXML::XPath.each(doc, '/Resources/ProfileCategoryResource/Children/ProfileItems/ProfileItem') do |item|
          data[:items] << parse_xml_profile_item(item)
        end
        REXML::XPath.each(doc, '/Resources/ProfileCategoryResource/ProfileItem') do |item|
          data[:items] << parse_xml_profile_item(item)
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory from XML data. Check that your URL is correct.")
      end

      def self.get_history(connection, path, num_months, end_date = Date.today, items_per_page = 10)
        month = end_date.month
        year = end_date.year
        history = []
        num_months.times do
          date = Date.new(year, month)
          data = self.get(connection, path, date, items_per_page)
          # If we get no data items back, there is no data at all before this date, so don't bother fetching it
          if data.items.empty?
            (num_months - history.size).times do
              history << Category.new(:children => [], :items => [])
            end
            break
          else
            history << data
          end
          month -= 1
          if (month == 0)
            year -= 1
            month = 12
          end
        end
        return history.reverse
      end

      def self.parse(connection, response)
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
      end


      def self.get(connection, path, for_date = Date.today, items_per_page = 10, recurse = false)
        # Load data from path
        options = {:profileDate => for_date.strftime("%Y%m"), :itemsPerPage => items_per_page}
        options[:recurse] = true if recurse == true
        response = connection.get(path, options)
        return Category.parse(connection, response)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory. Check that your URL is correct.")
      end
      
      def child(child_path)
        AMEE::Profile::Category.get(connection, "#{full_path}/#{child_path}")
      end

      def item(options)
        # Search fields - from most specific to least specific
        item = items.find{ |x| x[:uid] == options[:uid] || x[:name] == options[:name] || x[:dataItemUid] == options[:dataItemUid] || x[:dataItemLabel] == options[:dataItemLabel] }
        item ? AMEE::Profile::Item.get(connection, "#{full_path}/#{item[:path]}") : nil
      end

    end
  end
end
