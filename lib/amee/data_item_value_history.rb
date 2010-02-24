module AMEE
  module Data
    class ItemValueHistory

      def initialize(data = {})
        @type = data ? data[:type] : nil
        @values=data&&data[:values] ? data[:values] : []
        self.series=data[:series] if data[:series]
      end

      attr_accessor :values
      attr_accessor :path # the IV path corresponding to the series, without the /data
      
      def full_path
        "/data#{path}"
      end

      def series
        values.map {|x|
          [x.start_date,x.value]
        }
      end

      def series=(newseries)
        @values=newseries.map{|x|
          AMEE::Data::ItemValue.new(:value=>x[1],:start_date=>x[0])
        }
      end

      def value_at(time)
        selected=values.select{|x| x.start_date==time}
        raise_error AMEE::BadData("Multiple data item values matching one time.") if selected.length >1
        raise_error AMEE::BadData("No data item value for that time.") if selected.length ==0
        selected[0]
      end

      attr_accessor :connection
      attr_reader :type

      def self.from_json(json, path)
        # Read JSON
        data = {}
        data[:path] = path.gsub(/^\/data/, '')
        doc = JSON.parse(json)['itemValues']
        data[:values]=doc.map do |json_item_value|
          ItemValue.from_json(json_item_value,path)
        end
        data[:type]=data[:values][0].type
        # Create object
        ItemValueHistory.new(data)
      #rescue
      #  raise AMEE::BadData.new("Couldn't load DataItemValue from JSON. Check that your URL is correct.\n#{json}")
      end
      
      def self.from_xml(xml, path)
        # Read XML
        data = {}
        data[:path] = path.gsub(/^\/data/, '')
        doc = REXML::Document.new(xml)
        valuedocs=REXML::XPath.match(doc, '//DataItemValueResource')
        data[:values] = valuedocs.map do |xml_item_value|
          ItemValue.from_xml(xml_item_value,path)
        end
        data[:type]=data[:values][0].type
        # Create object
        ItemValueHistory.new(data)
      #rescue
      #  raise AMEE::BadData.new("Couldn't load DataItemValue from XML. Check that your URL is correct.\n#{xml}")
      end

      def self.get(connection, path)
        # Load data from path
        response = connection.get(path).body
        # Parse data from response
        data = {}
        value = ItemValueHistory.parse(connection, response, path)
        # Done
        return value
      #rescue
      #  raise AMEE::BadData.new("Couldn't load DataItemValue. Check that your URL is correct.")
      end

      def save!
        #stub
      end

      def delete!
        #stub
      end

      def create!
        #stub
      end

      def self.parse(connection, response, path) 
        if response.is_json?
          history = ItemValueHistory.from_json(response, path)
        else
          history = ItemValueHistory.from_xml(response, path)
        end
        # Store connection in object for future use
        history.connection = connection
        # Done
        return history
      #rescue
      #  raise AMEE::BadData.new("Couldn't load DataItemValue. Check that your URL is correct.\n#{response}")
      end
      
      def self.create(data_item, options = {})
        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
        # Store format if set
        format = options[:format]
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Third argument must be a hash of options!")
        end

        ##STUB

        if get_item == true
          get_options = {}
          get_options[:format] = format if format
          return AMEE::Data::ItemValue.get(data_item.connection, location)
        else
          return location
        end
      rescue
        raise AMEE::BadData.new("Couldn't create DataItemValue. Check that your information is correct.")
      end

      def self.update(connection, path, options = {})
        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
       

        ##STUB

        if get_item
          if response.body.empty?
            return AMEE::Data::ItemValue.get(connection, path)
          else
            return AMEE::Data::ItemValue.parse(connection, response.body)
          end
        end
      rescue
        raise AMEE::BadData.new("Couldn't update DataItemValue. Check that your information is correct.\n#{response}")
      end

      def self.delete(connection, path)
        ##STUB
      rescue
        raise AMEE::BadData.new("Couldn't delete DataItemValue. Check that your information is correct.")
      end      
    
    end
  end
end
