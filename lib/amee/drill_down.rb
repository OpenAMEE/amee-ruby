module AMEE
  module Data
    class DrillDown < AMEE::Data::Object

      def initialize(data = {})
        @choices = data ? data[:choices] : []
        @choice_name = data[:choice_name]
        @selections = data ? data[:selections] : []
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
          options << "#{key}=#{value}"
        end
        options << "#{@choice_name}=#{choice}"
        query_string = options.join "&"        
        DrillDown.get(connection, "#{full_path}?#{query_string}")
      end

      def self.from_json(json)
        # Parse json
        doc = JSON.parse(json)
        data = {}
        # Create object
        DrillDown.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DrillDown resource from JSON data. Check that your URL is correct.")
      end
      
      def self.from_xml(xml)
        # Parse XML
        doc = REXML::Document.new(xml)
        data = {}
        data[:choice_name] = REXML::XPath.first(doc, "/Resources/DrillDownResource/Choices/Name").text
        choices = []
        REXML::XPath.each(doc, "/Resources/DrillDownResource/Choices/Choices/Choice") do |c|
          choices << c.elements['Value'].text
        end
        data[:choices] = choices
        selections = {}
        REXML::XPath.each(doc, "/Resources/DrillDownResource/Selections/Choice") do |c|
          selections[c.elements['Name'].text] = c.elements['Value'].text
        end
        data[:selections] = selections
        # Create object
        DrillDown.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load DrillDown resource from XML data. Check that your URL is correct.")
      end

      def self.get(connection, path)
        # Load data from path
        response = connection.get(path)
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
      rescue
        raise AMEE::BadData.new("Couldn't load DrillDown resource. Check that your URL is correct.")
      end
      
    end
  end
end