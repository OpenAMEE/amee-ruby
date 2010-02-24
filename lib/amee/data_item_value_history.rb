module AMEE
  module Data
    class ItemValueHistory

      def initialize(data = {})
        @type = data ? data[:type] : nil
        @path = data ? data[:path] : nil
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
        ## STUB
      end

      def delete!
         # deprecated, as DI cannot exist without at least one point
        raise AMEE::NotSupported("Cannot create a Data Item Value History from scratch:
           at least one data point must always exist when the DI is created")
      end

      def create!
        # deprecated, as DI cannot exist without at least one point
        raise AMEE::NotSupported("Cannot create a Data Item Value History from scratch:
           at least one data point must exist when the DI is created")
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
    
    end
  end
end
