module AMEE
  module Profile
    class Item < AMEE::Profile::Object

      def initialize(data = {})
        @values = data ? data[:values] : []
        @total_amount = data[:total_amount]
        @total_amount_unit = data[:total_amount_unit]
        @start_date = data[:start_date] || data[:valid_from]
        @end_date = data[:end_date] || (data[:end] == true ? @start_date : nil )
        @data_item_uid = data[:data_item_uid]
        super
      end

      attr_reader :values
      attr_reader :total_amount
      attr_reader :total_amount_unit
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
        raise AMEE::BadData.new("Couldn't load ProfileItem from JSON data. Check that your URL is correct.")
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
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem from V2 JSON data. Check that your URL is correct.")
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
        raise AMEE::BadData.new("Couldn't load ProfileItem from XML data. Check that your URL is correct.")
      end

      def self.from_v2_xml(xml)
        # Parse XML
        doc = REXML::Document.new(xml)
        data = {}
        data[:profile_uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/Profile/@uid").to_s
        data[:data_item_uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/DataItem/@uid").to_s
        data[:uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/ProfileItem/@uid").to_s
        data[:name] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/ProfileItem/Name').text
        data[:path] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/Path').text || ""
        data[:total_amount] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/ProfileItem/Amount').text.to_f rescue nil
        data[:total_amount_unit] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/ProfileItem/Amount/@unit').to_s rescue nil
        data[:start_date] = DateTime.parse(REXML::XPath.first(doc, "/Resources/ProfileItemResource/ProfileItem/StartDate").text)
        data[:end_date] = DateTime.parse(REXML::XPath.first(doc, "/Resources/ProfileItemResource/ProfileItem/EndDate").text) rescue nil
        data[:values] = []
        REXML::XPath.each(doc, '/Resources/ProfileItemResource/ProfileItem/ItemValues/ItemValue') do |item|
          value_data = {}
          item.elements.each do |element|
            key = element.name
            value = element.text
            case key
              when 'Name', 'Path', 'Value', 'Unit'
                value_data[key.downcase.to_sym] = value
              when 'PerUnit'
                value_data[:per_unit] = value
            end
          end
          value_data[:uid] = item.attributes['uid'].to_s
          data[:values] << value_data
        end
        # Create object
        Item.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem from V2 XML data. Check that your URL is correct.")
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
        raise AMEE::BadData.new("Couldn't load ProfileItem from V2 ATOM data. Check that your URL is correct.")
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
          options[:startDate] = options[:start_date].amee2schema
        end
        options.delete(:start_date)
        if options[:end_date] && category.connection.version >= 2
          options[:endDate] = options[:end_date].amee2schema
        end
        options.delete(:end_date)
        if options[:duration] && category.connection.version >= 2
          options[:duration] = "PT#{options[:duration] * 86400}S"
        end
        # Load data from path
        response = connection.get(path, options)
        return Item.parse(connection, response)
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem. Check that your URL is correct.")
      end

      def self.create(category, data_item_uid, options = {})
        create_without_category(category.connection, category.full_path, data_item_uid, options)
      end

      def self.create_without_category(connection, path, data_item_uid, options = {})
        # Store format if set
        format = options[:format]
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Third argument must be a hash of options!")
        end
        # Set dates
        if options[:start_date] && connection.version < 2
          options[:profileDate] = options[:start_date].amee1_month
        elsif options[:start_date] && connection.version >= 2
          options[:startDate] = options[:start_date].amee2schema
        end
        options.delete(:start_date)
        if options[:end_date] && connection.version >= 2
          options[:endDate] = options[:end_date].amee2schema
        end        
        options.delete(:end_date)
        if options[:duration] && connection.version >= 2
          options[:duration] = "PT#{options[:duration] * 86400}S"
        end
        # Send data to path
        options.merge! :dataItemUid => data_item_uid
        response = connection.post(path, options)
        category = Category.parse(connection, response)
        options.merge!(:format => format) if format
        return category.item(options)
      rescue
        raise AMEE::BadData.new("Couldn't create ProfileItem. Check that your information is correct.")
      end

      def self.update(connection, path, options = {})
        response = connection.put(path, options)
        return Item.parse(connection, response)
      rescue
        raise AMEE::BadData.new("Couldn't update ProfileItem. Check that your information is correct.")
      end

      def update(options = {})
        AMEE::Profile::Item.update(connection, full_path, options)
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
