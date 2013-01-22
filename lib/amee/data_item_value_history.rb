# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'set'

module AMEE
  module Data
    class ItemValueHistory
      extend ParseHelper

      def initialize(data = {})
        @type = data ? data[:type] : nil
        @path = data ? data[:path] : nil
        @connection = data ? data[:connection] : nil
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
          [x.start_date.utc,x.value]
        }.sort {|x,y|
          x[0]<=>y[0]
        }
      end

      def times
        values.map {|x|
          x.start_date.utc
        }
      end

      def series=(newseries)
        raise AMEE::BadData.new("Series must have initial (Epoch) value") unless newseries.any?{|x| x[0]==Epoch}
        @values=newseries.map{|x|
          AMEE::Data::ItemValue.new(:value=>x[1],
            :start_date=>x[0],
            :path=>path,
            :connection=>connection,
            :type=>type
          )
        }
      end

      def value_at(time)
        selected=values.select{|x| x.start_date==time}
        raise AMEE::BadData.new("Multiple data item values matching one time.") if selected.length >1
        raise AMEE::BadData.new("No data item value for that time #{time}.") if selected.length ==0
        selected[0]
      end

      def values_at(times)
        times.map{|x| value_at(x)}
      end

      def connection=(con)
        @connection=con
        @values.each{|x| x.connection=con}
      end

      attr_reader :connection
      attr_reader :type

      def self.from_json(json, path)
        # Read JSON
        data = {}
        data[:path] = path.gsub(/^\/data/, '')
        doc = JSON.parse(json)['itemValues']
        doc=[JSON.parse(json)['itemValue']] unless doc
        data[:values]=doc.map do |json_item_value|
          ItemValue.from_json(json_item_value,path)
        end
        data[:type]=data[:values][0].type
        # Create object
        ItemValueHistory.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DataItemValueHistory from JSON. Check that your URL is correct.\n#{json}")
      end
      
      def self.from_xml(xml, path)
        # Read XML
        data = {}
        data[:path] = path.gsub(/^\/data/, '')
        doc = load_xml_doc(xml)
        valuedocs=doc.xpath('//ItemValue')
        raise  if valuedocs.length==0
        data[:values] = valuedocs.map do |xml_item_value|
          ItemValue.from_xml(xml_item_value,path)
        end
        data[:type]=data[:values][0].type
        # Create object
        ItemValueHistory.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DataItemValueHistory from XML. Check that your URL is correct.\n#{xml}")
      end

      def self.get(connection, path)
        # Load data from path
        response = connection.get(path,:valuesPerPage=>2).body
        # Parse data from response
        data = {}
        value = ItemValueHistory.parse(connection, response, path)
        # Done
        return value
      rescue
        raise AMEE::BadData.new("Couldn't load DataItemValueHistory. Check that your URL is correct.")
      end

      def save!
        raise AMEE::BadData.new("Can't save without a path") unless @path
        raise AMEE::BadData.new("Can't save without a connection") unless @connection
        origin=ItemValueHistory.get(connection,full_path)
        changes=compare(origin)
        changes[:updates].each do |update|
          # we've decided to identify these, but the version in the thing to be
          # saved is probably home made, so copy over the uid
          update.uid=origin.value_at(update.start_date).uid
          update.save!
        end
        changes[:insertions].each do |insertion|
          insertion.create!
        end
        changes[:deletions].each do |deletion|
          deletion.delete!
        end
      end

      def delete!
         # deprecated, as DI cannot exist without at least one point
        raise AMEE::NotSupported.new("Cannot delete all of history: at least one data point must always exist.")
      end

      def create!
        # deprecated, as DI cannot exist without at least one point
        raise AMEE::NotSupported.new("Cannot create a Data Item Value History from scratch: at least one data point must exist when the DI is created")
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
      rescue
        raise AMEE::BadData.new("Couldn't load DataItemValueHistory. Check that your URL is correct.\n#{response}")
      end

      def compare(origin)
        new=Set.new(times)
        old=Set.new(origin.times)
        {
          :insertions=>values_at(new-old),
          :deletions=>origin.values_at(old-new),
          :updates=>values_at(old&new)
        }
      end

    end
  end
end
