# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'active_support/core_ext/hash/conversions'
require 'active_support/inflector'

module AMEE
  module Profile
    class Item < AMEE::Profile::Object

      def initialize(data = {})
        @values = data ? data[:values] : []
        @total_amount = data[:total_amount]
        @total_amount_unit = data[:total_amount_unit]
        @amounts = data[:amounts] || []
        @notes = data[:notes] || []
        @start_date = data[:start_date] || data[:valid_from]
        @end_date = data[:end_date] || (data[:end] == true ? @start_date : nil )
        @data_item_uid = data[:data_item_uid]
        super
      end

      attr_reader :values
      attr_reader :total_amount
      attr_reader :total_amount_unit
      attr_reader :amounts
      attr_reader :notes
      attr_reader :start_date
      attr_reader :end_date
      attr_reader :data_item_uid

      # V1 compatibility
      def valid_from
        start_date
      end
      def end
        end_date.nil? ? false : start_date == end_date
      end

      def duration
        end_date.nil? ? nil : (end_date - start_date).to_f
      end

      def self.from_json(json)
        # Parse json
        doc = JSON.parse(json)
        data = {}
        data[:profile_uid] = doc['profile']['uid']
        data[:data_item_uid] = doc['profileItem']['dataItem']['uid']
        data[:uid] = doc['profileItem']['uid']
        data[:name] = doc['profileItem']['name']
        data[:path] = doc['path']
        data[:total_amount] = doc['profileItem']['amountPerMonth']
        data[:total_amount_unit] = "kg/month"
        data[:valid_from] = DateTime.strptime(doc['profileItem']['validFrom'], "%Y%m%d")
        data[:end] = doc['profileItem']['end'] == "false" ? false : true
        data[:values] = []
        doc['profileItem']['itemValues'].each do |item|
          value_data = {}
          item.each_pair do |key,value|
            case key
              when 'name', 'path', 'uid', 'value'
                value_data[key.downcase.to_sym] = value
            end
          end
          data[:values] << value_data
        end
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem from JSON data. Check that your URL is correct.\n#{json}")
      end

      def self.from_v2_json(json)
        # Parse json
        doc = JSON.parse(json)
        data = {}
        data[:profile_uid] = doc['profile']['uid']
        data[:data_item_uid] = doc['profileItem']['dataItem']['uid']
        data[:uid] = doc['profileItem']['uid']
        data[:name] = doc['profileItem']['name']
        data[:path] = doc['path']
        data[:total_amount] = doc['profileItem']['amount']['value'].to_f
        data[:total_amount_unit] = doc['profileItem']['amount']['unit']
        data[:start_date] = DateTime.parse(doc['profileItem']['startDate'])
        data[:end_date] = DateTime.parse(doc['profileItem']['endDate']) rescue nil
        data[:values] = []
        doc['profileItem']['itemValues'].each do |item|
          value_data = {}
          item.each_pair do |key,value|
            case key
              when 'name', 'path', 'uid', 'value', 'unit'
                value_data[key.downcase.to_sym] = value
              when 'perUnit'
                value_data[:per_unit] = value
            end
          end
          data[:values] << value_data
        end
        if doc['profileItem']['amounts']
          if doc['profileItem']['amounts']['amount']
            data[:amounts] = doc['profileItem']['amounts']['amount'].map do |item|
              {
                :type => item['type'],
                :value => item['value'].to_f,
                :unit => item['unit'],
                :per_unit => item['perUnit'],
                :default => (item['default'] == 'true'),
              }
            end
          end
          if doc['profileItem']['amounts']['note']
            data[:notes] = doc['profileItem']['amounts']['note'].map do |item|
              {
                :type => item['type'],
                :value => item['value'],
              }
            end
          end
        end
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem from V2 JSON data. Check that your URL is correct.\n#{json}")
      end

      def self.from_xml(xml)
        # Parse XML
        doc = REXML::Document.new(xml)
        data = {}
        data[:profile_uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/Profile/@uid").to_s
        data[:data_item_uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/DataItem/@uid").to_s
        data[:uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/ProfileItem/@uid").to_s
        data[:name] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/ProfileItem/Name').text
        data[:path] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/Path').text || ""
        data[:total_amount] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/ProfileItem/AmountPerMonth').text.to_f rescue nil
        data[:total_amount_unit] = "kg/month"
        data[:valid_from] = DateTime.strptime(REXML::XPath.first(doc, "/Resources/ProfileItemResource/ProfileItem/ValidFrom").text, "%Y%m%d")
        data[:end] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/ProfileItem/End').text == "false" ? false : true
        data[:values] = []
        REXML::XPath.each(doc, '/Resources/ProfileItemResource/ProfileItem/ItemValues/ItemValue') do |item|
          value_data = {}
          item.elements.each do |element|
            key = element.name
            value = element.text
            case key
              when 'Name', 'Path', 'Value'
                value_data[key.downcase.to_sym] = value
            end
          end
          value_data[:uid] = item.attributes['uid'].to_s
          data[:values] << value_data
        end
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem from XML data. Check that your URL is correct.\n#{xml}")
      end

      def self.xmlpathpreamble
        "/Resources/ProfileItemResource/"
      end

      def self.from_v2_xml(xml)
        # Parse XML
        @doc = load_xml_doc(xml)
        data = {}
        data[:profile_uid] = x 'Profile/@uid'
        data[:data_item_uid] = x 'DataItem/@uid'
        data[:uid] = x 'ProfileItem/@uid'
        data[:name] = x 'ProfileItem/Name'
        data[:path] = x('Path') || ""
        data[:total_amount] = x('ProfileItem/Amount').to_f rescue nil
        data[:total_amount_unit] = x 'ProfileItem/Amount/@unit' rescue nil
        data[:start_date] = DateTime.parse(x 'ProfileItem/StartDate')
        data[:end_date] = DateTime.parse(x 'ProfileItem/EndDate') rescue nil
        data[:values] = []
        @doc.xpath("#{xmlpathpreamble}ProfileItem/ItemValues/ItemValue").each do |item|
          value_data = {}
          item.elements.each do |element|
            key = element.name
            value = element.text
            case key
              when 'Name', 'Path', 'Value', 'Unit'
                value_data[key.downcase.to_sym] = value.blank? ? nil : value
              when 'PerUnit'
                value_data[:per_unit] = value
            end
          end
          value_data[:uid] = item.attributes['uid'].to_s
          data[:values] << value_data
        end
        data[:amounts] = @doc.xpath('/Resources/ProfileItemResource/ProfileItem/Amounts/Amount').map do |item|
          x = {
            :type => item.attribute('type').value,
            :value => item.text.to_f,
            :unit => item.attribute('unit').value,
          }
          x[:per_unit] = item.attribute('perUnit').value if item.attribute('perUnit')
          x[:default] = (item.attribute('default').value == 'true') if item.attribute('default')
          x
        end
        data[:notes] = @doc.xpath('/Resources/ProfileItemResource/ProfileItem/Amounts/Note').map do |item|
          {
            :type => item.attribute('type').value,
            :value => item.text,
          }
        end
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem from V2 XML data. Check that your URL is correct.\n#{xml}")
      end

      def self.from_v2_atom(response)
        # Parse XML
        doc = REXML::Document.new(response)
        data = {}
        data[:profile_uid] = REXML::XPath.first(doc, "/entry/@xml:base").to_s.match("/profiles/(.*?)/")[1]
        #data[:data_item_uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/DataItem/@uid").to_s
        data[:uid] = REXML::XPath.first(doc, "/entry/id").text.match("urn:item:(.*)")[1]
        data[:name] = REXML::XPath.first(doc, '/entry/title').text
        data[:path] = REXML::XPath.first(doc, "/entry/@xml:base").to_s.match("/profiles/.*?(/.*)")[1]
        data[:total_amount] = REXML::XPath.first(doc, '/entry/amee:amount').text.to_f rescue nil
        data[:total_amount_unit] = REXML::XPath.first(doc, '/entry/amee:amount/@unit').to_s rescue nil
        data[:start_date] = DateTime.parse(REXML::XPath.first(doc, "/entry/amee:startDate").text)
        data[:end_date] = DateTime.parse(REXML::XPath.first(doc, "/entry/amee:endDate").text) rescue nil
        data[:values] = []
        REXML::XPath.each(doc, '/entry/amee:itemValue') do |item|
          value_data = {}
          value_data[:name] = item.elements['amee:name'].text
          value_data[:value] = item.elements['amee:value'].text unless item.elements['amee:value'].text == "N/A"
          value_data[:path] = item.elements['link'].attributes['href'].to_s
          value_data[:unit] = item.elements['amee:unit'].text rescue nil
          value_data[:per_unit] = item.elements['amee:perUnit'].text rescue nil
          data[:values] << value_data
        end
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem from V2 ATOM data. Check that your URL is correct.\n#{response}")
      end

      def self.parse(connection, response)
        # Parse data from response
        if response.is_v2_json?
          item = Item.from_v2_json(response)
        elsif response.is_json?
          item = Item.from_json(response)
        elsif response.is_v2_atom?
          item = Item.from_v2_atom(response)
        elsif response.is_v2_xml?
          item = Item.from_v2_xml(response)
        else
          item = Item.from_xml(response)
        end
        # Store connection in object for future use
        item.connection = connection
        # Done
        return item
      end

     def self.get(connection, path, options = {})
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Third argument must be a hash of options!")
        end
        # Convert to AMEE options
        if options[:start_date] && category.connection.version < 2
          options[:profileDate] = options[:start_date].amee1_month
        elsif options[:start_date] && category.connection.version >= 2
          options[:startDate] = options[:start_date].xmlschema
        end
        options.delete(:start_date)
        if options[:end_date] && category.connection.version >= 2
          options[:endDate] = options[:end_date].xmlschema
        end
        options.delete(:end_date)
        if options[:duration] && category.connection.version >= 2
          options[:duration] = "PT#{options[:duration] * 86400}S"
        end
        # Load data from path
        response = connection.get(path, options).body
        return Item.parse(connection, response)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem. Check that your URL is correct.\n#{response}")
      end

      def self.create(category, data_item_uid, options = {})
        create_without_category(category.connection, category.full_path, data_item_uid, options)
      end

      def self.create_without_category(connection, path, data_item_uid, options = {})
        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
        # Store format if set
        format = options[:format]
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Third argument must be a hash of options!")
        end
        # Set dates
        if options[:start_date] && connection.version < 2
          options[:validFrom] = options[:start_date].amee1_date
        elsif options[:start_date] && connection.version >= 2
          options[:startDate] = options[:start_date].xmlschema
        end
        if options[:end_date] && connection.version >= 2
          options[:endDate] = options[:end_date].xmlschema
        end
        if options[:duration] && connection.version >= 2
          options[:duration] = "PT#{options[:duration] * 86400}S"
        end
        # Send data to path
        options.merge!(:representation => 'full') if (connection.version >= 2) && (get_item == true)
        options.merge! :dataItemUid => data_item_uid
        # POST
        response = connection.post(path, options)
        # Parse response
        category = response.body.empty? ? nil : Category.parse(connection, response.body, options)
        if response.headers_hash.has_key?('Location') && response.headers_hash['Location']
          location = response.headers_hash['Location'].match("https??://.*?(/.*)")[1]
        else
          location = category.full_path + "/" + category.items[0][:path]
        end
        if get_item == true
          if connection.version >= 2
            item = category.items.first
            item[:connection] = category.connection
            item[:profile_uid] = category.profile_uid
            item[:data_item_label] = item.delete(:dataItemLabel)
            item[:data_item_uid] = item.delete(:dataItemUid)
            item[:start_date] = item.delete(:startDate)
            item[:end_date] = item.delete(:endDate)
            item[:total_amount] = item.delete(:amount) || item.delete(:amountPerMonth)
            item[:total_amount_unit] = item.delete(:amount_unit) || "kg/month"
            values = []
            item[:values].each do |k,v|
              values << v.merge(:path => k.to_s)
            end
            item[:values] = values
            item[:path] = category.path + '/' + item[:path]
            return AMEE::Profile::Item.new(item)
          else
            get_options = {}
            get_options[:returnUnit] = options[:returnUnit] if options[:returnUnit]
            get_options[:returnPerUnit] = options[:returnPerUnit] if options[:returnPerUnit]
            get_options[:format] = format if format
            return AMEE::Profile::Item.get(connection, location, get_options)
          end
        else
          return location
        end
      rescue
        raise AMEE::BadData.new("Couldn't create ProfileItem. Check that your information is correct.\n#{response}")
      end

      def self.create_batch(category, items, options = {})
        create_batch_without_category(category.connection, category.full_path, items)
      end

      def self.create_batch_without_category(connection, category_path, items, options = {})
        if connection.format == :json
          options.merge! :profileItems => items
          post_data = options.to_json
        else
        options.merge!({:ProfileItems => items})
        post_data = options.to_xml(:root => "ProfileCategory", :skip_types => true, :skip_nil => true)
        end
        # Post to category
        response = connection.raw_post(category_path, post_data).body
        # Send back a category object containing all the created items
        unless response.empty?
          return AMEE::Profile::Category.parse_batch(connection, response)
        else
          return true
        end
      end

      def self.update(connection, path, options = {})
        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
        # Set dates
        if options[:start_date] && connection.version < 2
          options[:validFrom] = options[:start_date].amee1_date
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
        options.merge!(:representation => 'full') if (connection.version >= 2) && (get_item == true)
        # Go
        response = connection.put(path, options)
        if get_item
          if response.body.empty?
            return Item.get(connection, path)
          else
            return Item.parse(connection, response.body)
          end
        end
      rescue
        raise AMEE::BadData.new("Couldn't update ProfileItem. Check that your information is correct.\n#{response}")
      end

      def update(options = {})
        AMEE::Profile::Item.update(connection, full_path, options)
      end

      def self.update_batch(category, items)
        update_batch_without_category(category.connection, category.full_path, items)
      end

      def self.update_batch_without_category(connection, category_path, items)
        if connection.format == :json
          put_data = ({:profileItems => items}).to_json
        else
          put_data = ({:ProfileItems => items}).to_xml(:root => "ProfileCategory", :skip_types => true, :skip_nil => true)
        end
        # Post to category
        response = connection.raw_put(category_path, put_data).body
        # Send back a category object containing all the created items
        unless response.empty?
          return AMEE::Profile::Category.parse(connection, response, nil)
        else
          return true
        end
      end

      def self.delete(connection, path)
        connection.delete(path)
      rescue
        raise AMEE::BadData.new("Couldn't delete ProfileItem. Check that your information is correct.")
      end

      def value(name_or_path)
        val = values.find{ |x| x[:name] == name_or_path || x[:path] == name_or_path}
        val ? val[:value] : nil
      end

    end
  end
end
