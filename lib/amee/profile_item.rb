module AMEE
  module Profile
    class Item < AMEE::Profile::Object

      def initialize(data = {})
        @values = data ? data[:values] : []
        @total_amount_per_month = data[:total_amount_per_month]
        @valid_from = data[:valid_from]
        @data_item_uid = data[:data_item_uid]
        @end = data[:end]
        super
      end

      attr_reader :values
      attr_reader :total_amount_per_month
      attr_reader :valid_from
      attr_reader :end
      attr_reader :data_item_uid

      def self.from_json(json)
        # Parse json
        doc = JSON.parse(json)
        data = {}
        data[:profile_uid] = doc['profile']['uid']
        data[:data_item_uid] = doc['profileItem']['dataItem']['uid']
        data[:uid] = doc['profileItem']['uid']
        data[:name] = doc['profileItem']['name']
        data[:path] = doc['path']
        data[:total_amount_per_month] = doc['profileItem']['amountPerMonth']
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

      def self.from_xml(xml)
        # Parse XML
        doc = REXML::Document.new(xml)
        data = {}
        data[:profile_uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/Profile/@uid").to_s
        data[:data_item_uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/DataItem/@uid").to_s
        data[:uid] = REXML::XPath.first(doc, "/Resources/ProfileItemResource/ProfileItem/@uid").to_s
        data[:name] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/ProfileItem/Name').text
        data[:path] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/Path').text || ""
        data[:total_amount_per_month] = REXML::XPath.first(doc, '/Resources/ProfileItemResource/ProfileItem/AmountPerMonth').text.to_f rescue nil
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

      def self.get(connection, path, for_date = Date.today)
        # Load data from path
        response = connection.get(path, :profileDate => for_date.strftime("%Y%m"))
        # Parse data from response
        if response.is_json?
          cat = Item.from_json(response)
        else
          cat = Item.from_xml(response)
        end
        # Store connection in object for future use
        cat.connection = connection
        # Done
        return cat
      rescue
        raise AMEE::BadData.new("Couldn't load ProfileItem. Check that your URL is correct.")
      end

      def self.create(profile, data_item_uid, options = {})
        # Send data to path
        options.merge! :dataItemUid => data_item_uid
        profile.connection.post(profile.full_path, options)
      rescue
        raise AMEE::BadData.new("Couldn't create ProfileItem. Check that your information is correct.")
      end

      def update(options = {})
        connection.put(full_path, options)
      rescue
        raise AMEE::BadData.new("Couldn't update ProfileItem. Check that your information is correct.")
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
