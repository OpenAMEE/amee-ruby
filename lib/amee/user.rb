module AMEE
  module Admin

    class User < AMEE::Object

      attr_reader :login
      attr_reader :name
      attr_reader :email
      attr_reader :api_version

      def initialize(data = {})
        @login = data[:login]
        @name = data[:name]
        @email = data[:email]
        @api_version  = data[:api_version].to_f rescue nil
        super
      end

      def self.parse(connection, response)
        # Parse data from response
        if response.is_json?
          user = User.from_json(response)
        else
          user = User.from_xml(response)
        end
        # Store connection in object for future use
        user.connection = connection
        # Done
        return user
      end

      def self.from_json(json)
        # Read JSON
        doc = JSON.parse(json)
        data = {}
        data[:uid] = doc['user']['uid']
        data[:created] = DateTime.parse(doc['user']['created'])
        data[:modified] = DateTime.parse(doc['user']['modified'])
        data[:login] = doc['user']['login']
        data[:name] = doc['user']['name']
        data[:email] = doc['user']['email']
        data[:api_version] = doc['user']['apiVersion']
        # Create object
        User.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load User from JSON. Check that your URL is correct.\n#{json}")
      end

      def self.from_xml(xml)
        # Parse data from response into hash
        doc = REXML::Document.new(xml)
        data = {}
        data[:uid] = REXML::XPath.first(doc, "/User/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, "/User/@created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, "/User/@modified").to_s)
        data[:login] = REXML::XPath.first(doc, "/User/Login").text
        data[:name] = REXML::XPath.first(doc, "/User/Name").text
        data[:email] = REXML::XPath.first(doc, "/User/Email").text
        data[:api_version] = REXML::XPath.first(doc, "/User/ApiVersion").text
        # Create object
        User.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load User from XML. Check that your URL is correct.\n#{xml}")
      end

      def self.get(connection, path, options = {})
        # Load data from path
        response = connection.get(path, options).body
        # Parse response
        User.parse(connection, response)
      rescue
        raise AMEE::BadData.new("Couldn't load User. Check that your URL is correct.\n#{response}")
      end

      def update(options = {})
        response = connection.put(full_path, options).body
      rescue
        raise AMEE::BadData.new("Couldn't update User. Check that your information is correct.\n#{response}")
      end

      def self.create(connection, options = {})
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Second argument must be a hash of options!")
        end
        # Send data
        response = connection.post("", options).body
        # Parse response
        User.parse(connection, response)
      rescue
        raise AMEE::BadData.new("Couldn't create User. Check that your information is correct.\n#{response}")
      end

      def delete
        # Deleting can take a while... up the timeout to 120 seconds temporarily
        t = connection.timeout
        connection.timeout = 120
        connection.delete(full_path)
        connection.timeout = t
      rescue
        raise AMEE::BadData.new("Couldn't delete User. Check that your information is correct.")
      end

    end
  end
end