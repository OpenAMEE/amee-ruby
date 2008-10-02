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
        doc['children']['dataCategories'].each do |child|
          category_data = {}
          category_data[:name] = child['name']
          category_data[:path] = child['path']
          category_data[:uid] = child['uid']
          data[:children] << category_data
        end
        data[:items] = []
        if doc['children']['profileItems']['rows']
          doc['children']['profileItems']['rows'].each do |item|
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
            data[:items] << item_data
          end
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory from JSON data. Check that your URL is correct.")
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
        data[:items] = []
        REXML::XPath.each(doc, '/Resources/ProfileCategoryResource/Children/ProfileItems/ProfileItem') do |item|
          item_data = {}
          item_data[:values] = {}
          item.elements.each do |element|
            key = element.name
            value = element.text
            case key
              when 'dataItemLabel', 'dataItemUid', 'name', 'path'
                item_data[key.to_sym] = value
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
          item_data[:uid] = item.attributes['uid'].to_s
          data[:items] << item_data
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory from XML data. Check that your URL is correct.")
      end

      def self.get_history(connection, path, num_months, end_date = Date.today)
        month = end_date.month
        year = end_date.year
        history = []
        num_months.times do
          date = Date.new(year, month)
          data = self.get(connection, path, date)
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

      def self.get(connection, path, for_date = Date.today)
        # Load data from path
        response = connection.get(path, :profileDate => for_date.strftime("%Y%m"))
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
        raise AMEE::BadData.new("Couldn't load ProfileCategory. Check that your URL is correct.")
      end
      
      def child(child_path)
        AMEE::Profile::Category.get(connection, "#{full_path}/#{child_path}")
      end

      def item(label_or_uid)
        item = items.find{ |x| x[:dataItemLabel] == label_or_uid || x[:dataItemUid] == label_or_uid}
        item ? AMEE::Profile::Item.get(connection, "#{full_path}/#{item[:path]}") : nil
      end

    end
  end
end
