# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'cgi'

module AMEE
  module Data
    class DrillDown < AMEE::Data::Object

      def initialize(data = {})
        @choices = data ? data[:choices] : []
        @choice_name = data[:choice_name]
        @selections = data ? data[:selections] : []
        raise AMEE::ArgumentError.new('No choice_name specified') if @choice_name.nil?
        super
      end

      attr_reader :choices
      attr_reader :choice_name
      attr_reader :selections

      def path=(path)
        @path = path
      end

      def data_item_uid
        return nil if @choice_name != 'uid' || @choices.size != 1
        @choices[0]
      end

      def choose(choice)
        options = []
        @selections.each_pair do |key, value|
          options << "#{CGI::escape(key)}=#{CGI::escape(value)}"
        end
        options << "#{CGI::escape(@choice_name)}=#{CGI::escape(choice)}"
        query_string = options.join "&"        
        DrillDown.get(connection, "#{full_path}?#{query_string}")
      end

      def self.from_json(json)
        # Parse json
        doc = JSON.parse(json)
        data = {}
        data[:choice_name] = doc['choices']['name']
        choices = []
        doc['choices']['choices'].each do |c|
          choices << c['value']
        end
        data[:choices] = choices
        selections = {}
        doc['selections'].each do |c|
          selections[c['name']] = c['value']
        end
        data[:selections] = selections
        # Create object
        DrillDown.new(data)
      rescue Exception
        raise AMEE::BadData.new("Couldn't load DrillDown resource from JSON data. Check that your URL is correct.\n#{json}")
      end

      def self.xmlpathpreamble
        '/Resources/DrillDownResource/'
      end

      def self.from_xml(xml)
        # Parse XML
        @doc = load_xml_doc(xml)
        data = {}
        data[:choice_name] = x('Choices/Name') || x('Choices/name')
        data[:choices] = [x('Choices/Choices/Choice/Value') || x('Choices/Choice/value')].flatten
        names = x('Selections/Choice/Name') || x('Selections/Choice/name')
        values = x('Selections/Choice/Value') || x('Selections/Choice/value')
        data[:selections] = names && values ? Hash[*(names.zip(values)).flatten] : {}
        # Create object
        DrillDown.new(data)
      rescue Exception
        raise AMEE::BadData.new("Couldn't load DrillDown resource from XML data. Check that your URL is correct.\n#{xml}")
      end

      def self.get(connection, path)
        # Load data from path
        response = connection.get(path).body
        # Parse data from response
        if response.is_json?
          drill = DrillDown.from_json(response)
        else
          drill = DrillDown.from_xml(response)
        end
        # Store path in drill object - response does not include it
        drill.path = path.split('?')[0].gsub(/^\/data/, '')
        # Store connection in object for future use
        drill.connection = connection
        # Done
        return drill
      rescue Exception
        raise AMEE::BadData.new("Couldn't load DrillDown resource. Check that your URL is correct (#{path}).\n#{response}")
      end
      
    end
  end
end