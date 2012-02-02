module AMEE
  module Admin
    class ItemDefinitionList < AMEE::Collection
      def collectionpath
        '/admin/itemDefinitions'
      end
    end
    
    class ItemValueDefinitionList < AMEE::Collection
      def collectionpath
        "/admin/itemDefinitions/#{@uid}/itemValueDefinitions"
      end
    end
    
    class AlgorithmList < AMEE::Collection

      def initialize(connection,uid,options={})
        @uid=uid
        super(connection,options)
      end
      
      def klass
        Algorithm
      end
      
      def collectionpath
        "/admin/itemDefinitions/#{@uid}/algorithms"
      end

      def jsoncollector
        @doc['algorithms']
      end
      
      def xmlcollectorpath
        '/Resources/AlgorithmsResource/Environment/ItemDefinition/Algorithms/Algorithm'
      end

      def parse_json(p)
        data = {}
        data[:uid] = p['uid']
        data[:name] = p['name']
        data[:content] = p['content']
        data
      end
      
      def parse_xml(p)
        data = {}
        data[:uid] = x '@uid',:doc => p
        data[:name] = x 'Name',:doc => p  || data[:uid]
        data[:content] = x 'Content',:doc => p
        data
      end
    end
    
    class Algorithm < AMEE::Object
    
      def initialize(data = {})
        @itemdefuid=data[:itemdefuid]
        @name = data[:name]
        @uid = data[:uid]
        @content = data[:content]
        super
      end

      attr_reader :name,:uid,:itemdefuid, :content

      def self.parse(connection, response, is_list = true)
        # Parse data from response
        if response.is_json?
          algorithm = Algorithm.from_json(response)
        else
          algorithm = Algorithm.from_xml(response, is_list)
        end
        # Store connection in object for future use
        algorithm.connection = connection
        # Done
        return algorithm
      end

      def self.from_json(json)
        # Read JSON
        doc = JSON.parse(json)
        data = {}
        p=doc['algorithmResource']['algorithm']
        data[:uid] = p['uid']
        data[:itemdefuid] = p['itemDefinition']['uid']
        data[:created] = DateTime.parse(p['created'])
        data[:modified] = DateTime.parse(p['modified'])
        data[:name] = p['name']
        data[:content] = p['content']
        Algorithm.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load Algorithm from JSON. Check that your URL is correct.\n#{json}")
      end

      def self.xmlpathpreamble
        "/Resources//Algorithm/"
      end

      def self.from_xml(xml, is_list = true)
        prefix = is_list ? "/Resources/AlgorithmsResource/" : "/Resources/AlgorithmResource/"
        # Parse data from response into hash
        doc = REXML::Document.new(xml)
        data = {}
        data[:uid] = REXML::XPath.first(doc, prefix + "Algorithm/@uid").to_s
        data[:itemdefuid] = REXML::XPath.first(doc, prefix + "Algorithm/ItemDefinition/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, prefix + "Algorithm/@created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, prefix + "Algorithm/@modified").to_s)
        data[:name] = REXML::XPath.first(doc, prefix + "Algorithm/Name").text
        data[:content] = REXML::XPath.first(doc, prefix + "Algorithm/Content").text
        # Create object
        Algorithm.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load Algorithm from XML. Check that your URL is correct.\n#{xml}")
      end

      def self.get(connection, path, options = {})
        # Load data from path
        response = connection.get(path, options).body
        # Parse response
        algorithm = Algorithm.parse(connection, response, false)
        # Done
        return algorithm
      rescue
        raise AMEE::BadData.new("Couldn't load Algorithm. Check that your URL is correct.\n#{response}")
      end
      
      def self.update(connection, path, options = {})
        # Do we want to automatically fetch the item afterwards?
        get_item = options.delete(:get_item)
        get_item = true if get_item.nil?
        # Go
        response = connection.put(path, options)
        if get_item
          if response.body.empty?
            return AMEE::Admin::Algorithm.get(connection, path)
          else
            return AMEE::Admin::Algorithm.parse(connection, response.body)
          end
        end
      rescue
        raise AMEE::BadData.new("Couldn't update Algorithm. Check that your information is correct.\n#{response}")
      end

      def self.create(connection,itemdefuid, options = {})
         unless options.is_a?(Hash)
           raise AMEE::ArgumentError.new("Third argument must be a hash of options!")
         end
         # Send data
         response = connection.post("/admin/itemDefinitions/#{itemdefuid}/algorithms", options).body
         # Parse response
         algorithm = Algorithm.parse(connection, response, false)
        # Done
        return algorithm
      rescue
        raise AMEE::BadData.new("Couldn't create Algorithm. Check that your information is correct.\n#{response}")
      end

    end
    
  end
end
