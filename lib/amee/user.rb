module AMEE
  module Admin

    class User < AMEE::Object

      attr_reader :username
      attr_reader :name
      attr_reader :email
      attr_reader :api_version
      attr_reader :status

      def initialize(data = {})
        @username = data[:username]
        @name = data[:name]
        @email = data[:email]
        @status = data[:status]
        @api_version  = data[:api_version].to_f rescue nil
        @environment_uid = data[:environment_uid]
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
        data[:environment_uid] = doc['user']['environment']['uid']
        data[:uid] = doc['user']['uid']
        data[:created] = DateTime.parse(doc['user']['created'])
        data[:modified] = DateTime.parse(doc['user']['modified'])
        data[:username] = doc['user']['username']
        data[:name] = doc['user']['name']
        data[:email] = doc['user']['email']
        data[:api_version] = doc['user']['apiVersion']
        data[:status] = doc['user']['status']
        # Create object
        User.new(data)
      rescue
        raise AMEE::BadData.new("Couldn't load User from JSON. Check that your URL is correct.\n#{json}")
      end

      def self.from_xml(xml)
        # Parse data from response into hash
        doc = REXML::Document.new(xml)
        data = {}
        data[:environment_uid] = REXML::XPath.first(doc, "//Environment/@uid").to_s
        data[:uid] = REXML::XPath.first(doc, "//User/@uid").to_s
        data[:created] = DateTime.parse(REXML::XPath.first(doc, "//User/@created").to_s)
        data[:modified] = DateTime.parse(REXML::XPath.first(doc, "//User/@modified").to_s)
        data[:username] = REXML::XPath.first(doc, "//User/Username").text
        data[:name] = REXML::XPath.first(doc, "//User/Name").text
        data[:email] = REXML::XPath.first(doc, "//User/Email").text
        data[:api_version] = REXML::XPath.first(doc, "//User/ApiVersion").text
        data[:status] = REXML::XPath.first(doc, "//User/Status").text
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
        connection.put(full_path, options).body
        AMEE::Admin::User.get(connection, full_path)
      end

      def self.create(connection, environment_uid, options = {})
        prefix = environment_uid ? "/environments/#{environment_uid}" : "/admin"
        unless options.is_a?(Hash)
          raise AMEE::ArgumentError.new("Second argument must be a hash of options!")
        end
        # Send data
        response = connection.post("#{prefix}/users", options).body
        # Parse response
        User.parse(connection, response)
      rescue
        raise AMEE::BadData.new("Couldn't create User. Check that your information is correct.\n#{response}")
      end

      def delete
        connection.delete(full_path)
      rescue
        raise AMEE::BadData.new("Couldn't delete User. Check that your information is correct.")
      end

      def full_path
        prefix = @environment_uid ? "/environments/#{@environment_uid}" : "/admin"
        "#{prefix}/users/#{uid}"
      end

    end
  end
end