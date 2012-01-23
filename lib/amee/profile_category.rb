# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'date'

module AMEE
  module Profile
    class Category < AMEE::Profile::Object

      def initialize(data = {})
        @children = data ? data[:children] : []
        @items = data ? data[:items] : []
        @total_amount = data[:total_amount]
        @total_amount_unit = data[:total_amount_unit]
        @amounts = data[:amounts] || []
        @notes = data[:notes] || []
        @start_date = data[:start_date]
        @end_date = data[:end_date]
        @pager = data[:pager]
        super
      end

      attr_reader :children
      attr_reader :items
      attr_reader :total_amount
      attr_reader :total_amount_unit
      attr_reader :amounts
      attr_reader :notes
      attr_reader :pager

      def start_date
        @start_date || profile_date
      end

      def end_date
        @end_date
      end

      def self.parse_json_profile_item(item)
        item_data = {}
        item_data[:values] = {}
        item.each_pair do |key, value|
          case key
            when 'dataItemLabel', 'dataItemUid', 'name', 'path', 'uid'
              item_data[key.to_sym] = value
            when 'dataItem'
              item_data[:dataItemLabel] = value['Label']
              item_data[:dataItemUid] = value['uid']
            when 'label' # ignore these
              nil
            when 'created'
              item_data[:created] = DateTime.parse(value)
            when 'modified'
              item_data[:modified] = DateTime.parse(value)
            when 'validFrom'
              item_data[:validFrom] = DateTime.strptime(value, "%Y%m%d")
            when 'startDate'
              item_data[:startDate] = DateTime.parse(value)
            when 'endDate'
              item_data[:endDate] = DateTime.parse(value) rescue nil
            when 'end'
              item_data[:end] = (value == "true")
            when 'amountPerMonth'
              item_data[:amountPerMonth] = value.to_f
            when 'amount'
              item_data[:amount] = value['value'].to_f
              item_data[:amount_unit] = value['unit']
            when 'amounts'
              item_data[:amounts] = []
              if value['amount']
                value['amount'].each do |x|
                  d = {}
                  d[:type] = x['type']
                  d[:value] = x['value'].to_f
                  d[:unit] = x['unit']
                  d[:per_unit] = x['perUnit']
                  d[:default] = x['default'] == 'true'
                  item_data[:amounts] << d
                end
              end
              item_data[:notes] = []
              if value['note']
                value['note'].each do |x|
                  d = {}
                  d[:type] = x['type']
                  d[:value] = x['value']
                  item_data[:notes] << d
                end
              end
            when 'itemValues'
              value.each do |itemval|
                path = itemval['path'].to_sym
                item_data[:values][path.to_sym] = {}
                item_data[:values][path.to_sym][:name] = itemval['name']
                item_data[:values][path.to_sym][:value] = itemval['value']
                item_data[:values][path.to_sym][:unit] = itemval['unit']
                item_data[:values][path.to_sym][:per_unit] = itemval['perUnit']
              end
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

      def self.from_json(json, options)
        # Parse json
        doc = JSON.parse(json)
        data = {}
        data[:profile_uid] = doc['profile']['uid']
        data[:profile_date] = DateTime.strptime(doc['profileDate'], "%Y%m") rescue nil
        data[:name] = doc['dataCategory']['name']
        data[:path] = doc['path']
        data[:total_amount] = doc['totalAmountPerMonth']
        data[:total_amount_unit] = "kg/month"
        data[:pager] = AMEE::Pager.from_json(doc['children']['pager']) rescue nil
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
        raise AMEE::BadData.new("Couldn't load ProfileCategory from JSON data. Check that your URL is correct.\n#{json}")
      end

      def self.from_v2_json(json, options)
        # Parse json
        doc = JSON.parse(json)
        data = {}
        data[:profile_uid] = doc['profile']['uid']
        data[:start_date] = options[:start_date]
        data[:end_date] = options[:end_date]
        data[:name] = doc['dataCategory']['name']
        data[:path] = doc['path']
        data[:total_amount] = doc['totalAmount']['value'].to_f rescue nil
        data[:total_amount_unit] = doc['totalAmount']['unit'] rescue nil
        data[:pager] = AMEE::Pager.from_json(doc['pager']) rescue nil
        data[:children] = []
        if doc['profileCategories']
          doc['profileCategories'].each do |child|
            data[:children] << parse_json_profile_category(child)
          end
        end
        data[:items] = []
        profile_items = []
        profile_items.concat doc['profileItems'] rescue nil
        profile_items << doc['profileItem'] unless doc['profileItem'].nil?
        profile_items.each do |item|
          data[:items] << parse_json_profile_item(item)
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory from V2 JSON data. Check that your URL is correct.\n#{json}")
      end
            
      def self.parse_xml_profile_item(item)
        item_data = {}
        item_data[:values] = {}
        item.elements.each do |element|
          key = element.name
          value = element.text
          case key.downcase
            when 'dataitemlabel', 'dataitemuid', 'name', 'path'
              item_data[key.to_sym] = (value.blank? ? nil : value)
            when 'dataitem'
              item_data[:dataItemUid] = element.attributes['uid']
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
        item_data[:created] = DateTime.parse(item.attributes['created'].to_s) rescue nil
        item_data[:modified] = DateTime.parse(item.attributes['modified'].to_s) rescue nil
        item_data[:path] ||= item_data[:uid] # Fill in path if not retrieved from response
        return item_data
      end

      def self.from_v2_batch_json(json)
        # Parse JSON
        doc = JSON.parse(json)
        data = {}
        data[:profileItems] = []
        doc['profileItems'].each do |child|
          profile_item = {}
          profile_item[:uri] = child['uri'].to_s
          profile_item[:uid] = child['uid'].to_s
          data[:profileItems] << profile_item
        end
        return data
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory batch response from V2 JSON data. Check that your URL is correct.\n#{json}")
      end
      
      def self.parse_xml_profile_category(category)
        category_data = {}
        category_data[:name] = x('DataCategory/Name', :doc => category)
        category_data[:path] = x('DataCategory/Path', :doc => category)
        category_data[:uid] = x('DataCategory/@uid', :doc => category)
        category_data[:totalAmountPerMonth] = x('TotalAmountPerMonth', :doc => category).to_f rescue nil
        category_data[:children] = []
        category_data[:items] = []
        category.xpath('Children/ProfileCategories/ProfileCategory').each do |child|
          category_data[:children] << parse_xml_profile_category(child)
        end
        category.xpath('Children/ProfileItems/ProfileItem').each do |child|
          category_data[:items] << parse_xml_profile_item(child)
        end
        return category_data
      end

      def self.from_xml(xml, options)
        # Parse XML
        @doc = load_xml_doc(xml)
        data = {}
        data[:profile_uid] = x("/Resources/ProfileCategoryResource/Profile/@uid")
        data[:profile_date] = DateTime.strptime(x("/Resources/ProfileCategoryResource/ProfileDate"), "%Y%m")
        data[:name] = x('/Resources/ProfileCategoryResource/DataCategory/Name | /Resources/ProfileCategoryResource/DataCategory/name')
        data[:path] = x('/Resources/ProfileCategoryResource/Path | /Resources/ProfileCategoryResource/DataCategory/path') || ""
        data[:path] = "/#{data[:path]}" if data[:path].slice(0,1) != '/'
        data[:total_amount] = x('/Resources/ProfileCategoryResource/TotalAmountPerMonth').to_f rescue nil
        data[:total_amount_unit] = "kg/month"
        data[:pager] = AMEE::Pager.from_xml(@doc.xpath('//Pager').first)
        data[:children] = []
        @doc.xpath('/Resources/ProfileCategoryResource/Children/ProfileCategories/DataCategory | /Resources/ProfileCategoryResource/Children/DataCategories/DataCategory').each do |child|
          category_data = {}
          category_data[:name] = x('Name | name', :doc => child)
          category_data[:path] = x('Path | path', :doc => child)
          category_data[:uid] = x('@uid', :doc => child)
          data[:children] << category_data
        end
        @doc.xpath('/Resources/ProfileCategoryResource/Children/ProfileCategories/ProfileCategory').each do |child|
          data[:children] << parse_xml_profile_category(child)
        end
        data[:items] = []
        @doc.xpath('/Resources/ProfileCategoryResource/Children/ProfileItems/ProfileItem').each do |item|
          data[:items] << parse_xml_profile_item(item)
        end
        @doc.xpath('/Resources/ProfileCategoryResource/ProfileItem').each do |item|
          data[:items] << parse_xml_profile_item(item)
        end
        @doc.xpath('/Resources/ProfileCategoryResource/ProfileItems/ProfileItem').each do |item|
          data[:items] << parse_xml_profile_item(item)
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory from XML data. Check that your URL is correct.\n#{xml}")
      end

      def self.parse_v2_xml_profile_item(item)
        item_data = {}
        item_data[:values] = {}
        item.elements.each do |element|
          key = element.name
          case key.downcase
            when 'name', 'path'
              item_data[key.downcase.to_sym] = element.text
            when 'dataitem'
              item_data[:dataItemLabel] = x('Label', :doc => element)
              item_data[:dataItemUid] = element.attributes['uid'].to_s
            when 'validfrom'
              item_data[:validFrom] = DateTime.strptime(element.text, "%Y%m%d")
            when 'startdate'
              item_data[:startDate] = DateTime.parse(element.text)
            when 'enddate'
              item_data[:endDate] = DateTime.parse(element.text) if element.text.present?
            when 'end'
              item_data[:end] = (element.text == "true")
            when 'amount'
              item_data[:amount] = element.text.to_f
              item_data[:amount_unit] = element.attributes['unit'].to_s
            when 'amounts'
              element.elements.each do |x|
                case x.name
                when 'Amount'
                  item_data[:amounts] ||= []
                  d = {}
                  d[:type] = x.attributes['type'].to_s
                  d[:value] = x.text.to_f
                  d[:unit] = x.attributes['unit'].to_s
                  d[:per_unit] = x.attributes['perUnit'].to_s if x.attributes['perUnit']
                  d[:default] = x.attributes['default'].to_s == 'true'
                  item_data[:amounts] << d
                when 'Note'
                  item_data[:notes] ||= []
                  d = {}
                  d[:type] = x.attributes['type'].to_s
                  d[:value] = x.text
                  item_data[:notes] << d
                end
              end
            when 'itemvalues'
              element.elements.each do |itemvalue|
                path = x('Path', :doc => itemvalue)
                item_data[:values][path.to_sym] = {}
                item_data[:values][path.to_sym][:name] = x('Name', :doc => itemvalue)
                item_data[:values][path.to_sym][:value] = x('Value', :doc => itemvalue) || "0"
                item_data[:values][path.to_sym][:unit] = x('Unit', :doc => itemvalue)
                item_data[:values][path.to_sym][:per_unit] = x('PerUnit', :doc => itemvalue)
              end
            else
              item_data[:values][key.to_sym] = element.text
          end
        end
        item_data[:uid] = item.attributes['uid'].to_s
        item_data[:created] = DateTime.parse(item.attributes['created'].to_s) rescue nil
        item_data[:modified] = DateTime.parse(item.attributes['modified'].to_s) rescue nil
        item_data[:path] ||= item_data[:uid] # Fill in path if not retrieved from response
        return item_data
      end

      def self.from_v2_xml(xml, options)
        # Parse XML
        @doc = load_xml_doc(xml)
        data = {}
        data[:profile_uid] = x("/Resources/ProfileCategoryResource/Profile/@uid")
        raise if data[:profile_uid].nil? # Check that the XML is remotely valid
        data[:start_date] = options[:start_date]
        data[:end_date] = options[:end_date]
        data[:name] = x('/Resources/ProfileCategoryResource/DataCategory/Name')
        data[:path] = x('/Resources/ProfileCategoryResource/Path') || ""
        data[:total_amount] = x('/Resources/ProfileCategoryResource/TotalAmount').to_f rescue nil
        data[:total_amount_unit] = x('/Resources/ProfileCategoryResource/TotalAmount/@unit').to_s rescue nil
        data[:pager] = AMEE::Pager.from_xml(@doc.xpath('//Pager').first)
        data[:children] = []
        @doc.xpath('/Resources/ProfileCategoryResource/ProfileCategories/DataCategory').each do |child|
          category_data = {}
          category_data[:name] = x('Name', :doc => child)
          category_data[:path] = x('Path', :doc => child)
          category_data[:uid] = x('@uid', :doc => child)
          data[:children] << category_data
        end
        @doc.xpath('/Resources/ProfileCategoryResource/Children/ProfileCategories/ProfileCategory').each do |child|
          data[:children] << parse_xml_profile_category(child)
        end
        data[:items] = []
        @doc.xpath('/Resources/ProfileCategoryResource/ProfileItems/ProfileItem').each do |item|
          data[:items] << parse_v2_xml_profile_item(item)
        end
        @doc.xpath('/Resources/ProfileCategoryResource/ProfileItem').each do |item|
          data[:items] << parse_v2_xml_profile_item(item)
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory from V2 XML data. Check that your URL is correct.\n#{xml}")
      end

      def self.from_v2_batch_xml(xml)
        # Parse XML
        @doc = load_xml_doc(xml)
        data = {}
        data[:profileItems] = []
        @doc.xpath('/Resources/ProfileItems/ProfileItem').each do |child|
          profile_item = {}
          profile_item[:uri] = x('uri', :doc => child)
          profile_item[:uid] = x('uid', :doc => child)
          data[:profileItems] << profile_item
        end
        return data
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory batch response from V2 XML data. Check that your URL is correct.\n#{xml}")
      end
      
      def self.from_v2_atom(response, options)
        # Parse XML
        @doc = load_xml_doc(response)
        data = {}
        data[:profile_uid] = x("/feed/@base").match("/profiles/(.*?)/")[1]
        data[:start_date] = options[:start_date]
        data[:end_date] = options[:end_date]
        data[:name] = x('/feed/name')
        data[:path] = x("/feed/@base").match("/profiles/.*?(/.*)")[1]
        data[:total_amount] = x('/feed/totalAmount').to_f rescue nil
        data[:total_amount_unit] = x('/feed/totalAmount/@unit') rescue nil
        data[:children] = []
        @doc.xpath('/feed/categories/category').each do |child|
          category_data = {}
#          category_data[:path] = child.text
          category_data[:path] = child.text
#          category_data[:uid] = child.attributes['uid'].to_s
          data[:children] << category_data
        end
#        @doc.xpath('/Resources/ProfileCategoryResource/Children/ProfileCategories/ProfileCategory').each do |child|
#          data[:children] << parse_xml_profile_category(child)
#        end
        data[:items] = []
        @doc.xpath('/feed/entry').each do |entry|
          item = {}
          item[:uid] = x('id', :doc => entry).match("urn:item:(.*)")[1]
          item[:name] = x('title', :doc => entry)
          item[:path] = item[:uid]
#          data[:dataItemLabel].should == "gas"
#          data[:dataItemUid].should == "66056991EE23"
          item[:amount] = x('amount', :doc => entry).to_f rescue nil
          item[:amount_unit] = x('amount/@unit', :doc => entry)
          item[:startDate] = DateTime.parse(x('startDate', :doc => entry))
          item[:endDate] = DateTime.parse(x('endDate', :doc => entry)) rescue nil
          item[:values] = {}
          entry.elements.each do |itemvalue|
            if itemvalue.name == 'itemValue'
              path = x('link/@href', :doc => itemvalue).match(".*/(.*)")[1]
              i = {}
              i[:path] = path
              i[:name] = x('name', :doc => itemvalue)
              i[:value] = x('value', :doc => itemvalue) 
              i.delete(:value) if i[:value] == "N/A"
              i[:value] ||= "0"
              i[:unit] = x('unit', :doc => itemvalue) 
              i[:per_unit] = x('perUnit', :doc => itemvalue) 
              item[:values][path.to_sym] = i
            end
          end
          data[:items] << item
        end
        # Create object
        Category.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory from V2 Atom data. Check that your URL is correct.\n#{response}")
      end

      def self.get_history(connection, path, num_months, end_date = Date.today, items_per_page = 10)
        month = end_date.month
        year = end_date.year
        history = []
        num_months.times do
          date = Date.new(year, month)
          data = self.get(connection, path, :start_date => date, :itemsPerPage => items_per_page)
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

      def self.parse(connection, response, options)
        # Parse data from response
        if response.is_v2_json?
          cat = Category.from_v2_json(response, options)
        elsif response.is_json?
          cat = Category.from_json(response, options)
        elsif response.is_v2_atom?
          cat = Category.from_v2_atom(response, options)
        elsif response.is_v2_xml?
          cat = Category.from_v2_xml(response, options)
        elsif response.is_xml?
          cat = Category.from_xml(response, options)
        end
        # Store connection in object for future use
        cat.connection = connection
        # Done
        return cat
      end

      def self.parse_batch(connection, response)
        if response.is_v2_json?
          return Category.from_v2_batch_json(response)
        elsif response.is_v2_xml?
          return Category.from_v2_batch_xml(response)
        else
          return self.parse(connection, response, nil)
        end
      end
      
      def self.get(connection, path, orig_options = {})
        unless orig_options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Third argument must be a hash of options!")
        end
        # Convert to AMEE options
        options = orig_options.clone
        if options[:start_date] && connection.version < 2
          options[:profileDate] = options[:start_date].amee1_month 
        elsif options[:start_date] && connection.version >= 2
          options[:startDate] = options[:start_date].xmlschema
        end
        options.delete(:start_date)
        if options[:end_date] && connection.version >= 2
          options[:endDate] = options[:end_date].xmlschema
        end
        options.delete(:end_date)
        if options[:duration] && connection.version >= 2
          options[:duration] = "PT#{options[:duration] * 86400}S"
        end
        # Load data from path
        response = connection.get(path, options).body
        return Category.parse(connection, response, orig_options)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileCategory. Check that your URL is correct.\n#{response}")
      end

      def child(child_path)
        AMEE::Profile::Category.get(connection, "#{full_path}/#{child_path}")
      end

      def item(options)
        # Search fields - from most specific to least specific
        item = items.find{ |x| x[:uid] == options[:uid] || x[:name] == options[:name] || x[:dataItemUid] == options[:dataItemUid] || x[:dataItemLabel] == options[:dataItemLabel] }
        # Pass through some options
        new_opts = {}
        new_opts[:returnUnit] = options[:returnUnit] if options[:returnUnit]
        new_opts[:returnPerUnit] = options[:returnPerUnit] if options[:returnPerUnit]
        new_opts[:format] = options[:format] if options[:format]
        item ? AMEE::Profile::Item.get(connection, "#{full_path}/#{item[:path]}", new_opts) : nil
      end

    end
  end
end
