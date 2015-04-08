# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'pp'

module AMEE
  module Data
    class Item < AMEE::Data::Object

      def initialize(data = {})
        @values = data[:values]
        @choices = data[:choices]
        @label = data[:label]
        @item_definition_uid = data[:item_definition]
        @total_amount = data[:total_amount]
        @total_amount_unit = data[:total_amount_unit]
        @amounts = data[:amounts] || []
        @notes = data[:notes] || []
        @start_date = data[:start_date]
        @category_uid = data[:category_uid]
        super
      end

      attr_reader :values
      attr_reader :choices
      attr_reader :label
      attr_reader :total_amount
      attr_reader :total_amount_unit
      attr_reader :amounts
      attr_reader :notes
      attr_reader :start_date
      attr_reader :category_uid
      attr_reader :item_definition_uid

      def item_definition
        return nil unless item_definition_uid
        @item_definition ||= AMEE::Admin::ItemDefinition.load(connection,item_definition_uid)
      end

      def self.from_json(body)
        json = JSON.parse(body, :symbolize_names => true)
        new({
          amounts: json[:output][:amounts],
          notes: json[:output][:notes]
        })
      end

      def self.from_xml(xml)
        # Parse data from response into hash
        doc = REXML::Document.new(xml)
        begin
          data = {}
          data[:uid] = REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/@uid").to_s
          data[:created] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/@created").to_s)
          data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/@modified").to_s)
          data[:name] = (REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/Name') || REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/name')).text
          data[:path] = (REXML::XPath.first(doc, '/Resources/DataItemResource/Path') || REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/path')).text
          data[:label] = (REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/Label') || REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/label')).text
          data[:item_definition] = REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/ItemDefinition/@uid').to_s
          data[:category_uid] = REXML::XPath.first(doc, '/Resources/DataItemResource/DataItem/DataCategory/@uid').to_s
          # Read v2 total
          data[:total_amount] = REXML::XPath.first(doc, '/Resources/DataItemResource/Amount').text.to_f rescue nil
          data[:total_amount_unit] = REXML::XPath.first(doc, '/Resources/DataItemResource/Amount/@unit').to_s rescue nil
          # Read v1 total
          if data[:total_amount].nil?
            data[:total_amount] = REXML::XPath.first(doc, '/Resources/DataItemResource/AmountPerMonth').text.to_f rescue nil
            data[:total_amount_unit] = "kg/month"
          end
          data[:amounts] = []
          REXML::XPath.each(doc,'/Resources/DataItemResource/Amounts/Amount') do |amount|
            amount_data = {}
            amount_data[:type] = amount.attribute('type').value
            amount_data[:value] = amount.text.to_f
            amount_data[:unit] = amount.attribute('unit').value
            amount_data[:per_unit] = amount.attribute('perUnit').value if amount.attribute('perUnit')
            amount_data[:default] = (amount.attribute('default').value == 'true') if amount.attribute('default')
            data[:amounts] << amount_data
          end
          data[:notes] = []
          REXML::XPath.each(doc,'/Resources/DataItemResource/Amounts/Note') do |note|
            note_data = {}
            note_data[:type] = note.attribute('type').value
            note_data[:value] = note.text
            data[:notes] << note_data
          end
          # Get values
          data[:values] = []
          REXML::XPath.each(doc, '/Resources/DataItemResource/DataItem/ItemValues/ItemValue') do |value|
            value_data = {}
            value_data[:name] = (value.elements['Name'] || value.elements['name']).text
            value_data[:path] = (value.elements['Path'] || value.elements['path']).text
            value_data[:value] = (value.elements['Value'] || value.elements['value']).text
            value_data[:drill] = value.elements['ItemValueDefinition'].elements['DrillDown'].text == "false" ? false : true rescue nil
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
          data[:start_date] = DateTime.parse(REXML::XPath.first(doc, "/Resources/DataItemResource/DataItem/StartDate").text) rescue nil
          # Create object
          Item.new(data)
        rescue
          raise AMEE::BadData.new("Couldn't load DataItem from XML. Check that your URL is correct.\n#{xml}")
        end
      end


      def self.get(connection, path, options = {})
        # Load data from path
        item = get_and_parse(connection, path, options)
        # Store connection in object for future use
        item.connection = connection
        # Done
        return item
      end

      def self.parse(connection, response)
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
        # Create a data item!
        options[:newObjectType] = "DI"
        # Send data to path
        response = connection.post(path, options)
        if response.headers_hash.has_key?('Location') && response.headers_hash['Location']
          location = response.headers_hash['Location'].match("https??://.*?(/.*)")[1]
        else
          category = Category.parse(connection, response.body)
          location = category.full_path + "/" + category.items[0][:path]
        end
        if get_item == true
          get_options = {}
          get_options[:format] = format if format
          return AMEE::Data::Item.get(connection, location, get_options)
        else
          return location
        end
      rescue
        raise AMEE::BadData.new("Couldn't create DataItem. Check that your information is correct.\n#{response}")
      end

      def self.update(connection, path, options = {})
        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
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
        raise AMEE::BadData.new("Couldn't update DataItem. Check that your information is correct.\n#{response}")
      end

      def update(options = {})
        AMEE::Data::Item.update(connection, full_path, options)
      end

      def self.delete(connection, path)
        connection.delete(path)
      rescue
        raise AMEE::BadData.new("Couldn't delete DataItem. Check that your information is correct.")
      end

      def value(name_or_path_or_uid)
        val = values.find{ |x| x[:name] == name_or_path_or_uid || x[:path] == name_or_path_or_uid || x[:uid] == name_or_path_or_uid}
        val ? val[:value] : nil
      end

    end
  end
end
