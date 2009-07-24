module AMEE
  module Data
    class Item < AMEE::Data::Object

      def initialize(data = {})
        @values = data[:values]
        @choices = data[:choices]
        @label = data[:label]
        @item_definition = data[:item_definition]
        @total_amount = data[:total_amount]
        @total_amount_unit = data[:total_amount_unit]
        super
      end

      attr_reader :values
      attr_reader :choices
      attr_reader :label
      attr_reader :item_definition
      attr_reader :total_amount
      attr_reader :total_amount_unit

      def self.from_json(json)
        # Read JSON
        doc = JSON.parse(json)
        data = {}
        data[:uid] = doc['dataItem']['uid']
        data[:created] = DateTime.parse(doc['dataItem']['created'])
        data[:modified] = DateTime.parse(doc['dataItem']['modified'])
        data[:name] = doc['dataItem']['name']
        data[:path] = doc['path']
        data[:label] = doc['dataItem']['label']
        data[:item_definition] = doc['dataItem']['itemDefinition']['uid']
        # Read v2 total
        data[:total_amount] = doc['amount']['value'] rescue nil
        data[:total_amount_unit] = doc['amount']['unit'] rescue nil
        # Read v1 total
        if data[:total_amount].nil?
          data[:total_amount] = doc['amountPerMonth'] rescue nil
          data[:total_amount_unit] = "kg/month"
        end
        # Get values
        data[:values] = []
        doc['dataItem']['itemValues'].each do |value|
          value_data = {}
          value_data[:name] = value['name']
          value_data[:path] = value['path']
          value_data[:value] = value['value']
          value_data[:uid] = value['uid']
          data[:values] << value_data
        end
        # Get choices
        data[:choices] = []
        doc['userValueChoices']['choices'].each do |choice|
          choice_data = {}
          choice_data[:name] = choice['name']
          choice_data[:value] = choice['value']
          data[:choices] << choice_data
        end
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DataItem from JSON. Check that your URL is correct.\n#{json}")
      end
      
      def self.from_xml(xml)
        # Parse data from response into hash
        doc = REXML::Document.new(xml)
        data = {}
        data[:uid] = REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/@created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/@modified").to_s)
        data[:name] = (REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/Name') || REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/name')).text
        data[:path] = (REXML::XPath.first(doc, '/Resources/DataItemResource/Path') || REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/path')).text
        data[:label] = (REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/Label') || REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/label')).text
        data[:item_definition] = REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/ItemDefinition/@uid').to_s
        # Read v2 total
        data[:total_amount] = REXML::XPath.first(doc, '/Resources/DataItemResource/Amount').text.to_f rescue nil
        data[:total_amount_unit] = REXML::XPath.first(doc, '/Resources/DataItemResource/Amount/@unit').to_s rescue nil
        # Read v1 total
        if data[:total_amount].nil?
          data[:total_amount] = REXML::XPath.first(doc, '/Resources/DataItemResource/AmountPerMonth').text.to_f rescue nil
          data[:total_amount_unit] = "kg/month"
        end
        # Get values
        data[:values] = []
        REXML::XPath.each(doc, '/Resources/DataItemResource/DataItem/ItemValues/ItemValue') do |value|
          value_data = {}
          value_data[:name] = (value.elements['Name'] || value.elements['name']).text
          value_data[:path] = (value.elements['Path'] || value.elements['path']).text
          value_data[:value] = (value.elements['Value'] || value.elements['value']).text
          value_data[:uid] = value.attributes['uid'].to_s
          data[:values] << value_data
        end
        # Get choices
        data[:choices] = []
        REXML::XPath.each(doc, '/Resources/DataItemResource/Choices/Choices/Choice') do |choice|
          choice_data = {}
          choice_data[:name] = (choice.elements['Name']).text
          choice_data[:value] = (choice.elements['Value']).text || ""
          data[:choices] << choice_data
        end
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DataItem from XML. Check that your URL is correct.\n#{xml}")
      end

      
      def self.get(connection, path, options = {})
        # Load data from path
        response = connection.get(path, options).body
        # Parse data from response
        if response.is_json?
          item = Item.from_json(response)
        else
          item = Item.from_xml(response)
        end
        # Store connection in object for future use
        item.connection = connection
        # Done
        return item
      rescue
        raise AMEE::BadData.new("Couldn't load DataItem. Check that your URL is correct.\n#{response}")
      end

      def self.create_batch_without_category(connection, category_path, items, options = {})
        if connection.format == :json
          options.merge! :profileItems => items
          post_data = options.to_json
        else
        options.merge!({:DataItems => items})
        post_data = options.to_xml(:root => "DataCategory", :skip_types => true, :skip_nil => true)
        end
        # Post to category
        response = connection.raw_post(category_path, post_data).body
        # Send back a category object containing all the created items
        unless response.empty?
          return AMEE::Data::Category.parse(connection, response)
        else
          return true
        end
      end

      def self.create(category, options = {})
        create_without_category(category.connection, category.full_path, options)
      end

      def self.create_without_category(connection, path, options = {})
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
        options.delete(:start_date)
        if options[:end_date] && connection.version >= 2
          options[:endDate] = options[:end_date].xmlschema
        end
        options.delete(:end_date)
        if options[:duration] && connection.version >= 2
          options[:duration] = "PT#{options[:duration] * 86400}S"
        end
        # Create a data item!
        options[:newObjectType] = "DI"
        # Send data to path
        response = connection.post(path, options)
#        if response['Location']
#          location = response['Location'].match("http://.*?(/.*)")[1]
#        else
#          category = Category.parse(connection, response.body)
#          location = category.full_path + "/" + category.items[0][:path]
#        end
#        if get_item == true
#          get_options = {}
#          get_options[:format] = format if format
#          return AMEE::Data::Item.get(connection, location, get_options)
#        else
#          return location
#        end
      rescue
        raise AMEE::BadData.new("Couldn't create DataItem. Check that your information is correct.\n#{response}")
      end

      def update(options = {})
        response = connection.put(full_path, options).body
      rescue
        raise AMEE::BadData.new("Couldn't update DataItem. Check that your information is correct.\n#{response}")
      end

      def value(name_or_path_or_uid)
        val = values.find{ |x| x[:name] == name_or_path_or_uid || x[:path] == name_or_path_or_uid || x[:uid] == name_or_path_or_uid}
        val ? val[:value] : nil
      end

    end
  end
end
