module AMEE
  module Profile
    class ProfileList < Array
      
      def initialize(connection, options = {})
        # Load data from path
        response = connection.get('/profiles', options).body
        # Parse data from response
        if response.is_json?
          # Read JSON
          doc = JSON.parse(response)
          @pager = AMEE::Pager.from_json(doc['pager'])
          doc['profiles'].each do |p|
            data = {}
            data[:uid] = p['uid']
            data[:created] = DateTime.parse(p['created'])
            data[:modified] = DateTime.parse(p['modified'])
            data[:name] = p['name']
            data[:path] = "/#{p['path']}"
            # Create profile
            profile = Profile.new(data)
            # Store in array
            self << profile
          end
        else
          # Read XML
          doc = REXML::Document.new(response)
          @pager = AMEE::Pager.from_xml(REXML::XPath.first(doc, '/Resources/ProfilesResource/Pager'))
          REXML::XPath.each(doc, '/Resources/ProfilesResource/Profiles/Profile') do |p|
            data = {}
            data[:uid] = p.attributes['uid'].to_s
            data[:created] = DateTime.parse(p.attributes['created'].to_s)
            data[:modified] = DateTime.parse(p.attributes['modified'].to_s)
            data[:name] = p.elements['Name'].text || data[:uid]
            data[:path] = "/#{p.elements['Path'].text || data[:uid]}"
            # Create profile
            profile = Profile.new(data)
            # Store connection in profile object
            profile.connection = connection
            # Store in array
            self << profile
          end
        end
      rescue
        raise AMEE::BadData.new("Couldn't load Profile list.")
      end
      
      attr_reader :pager
      
    end

    class Profile < AMEE::Profile::Object

      # backwards compatibility
      def self.list(connection)
        ProfileList.new(connection)
      end

      def self.create(connection)
        # Create new profile
        response = connection.post('/profiles', :profile => true).body
        # Parse data from response
        if response.is_json?
          # Read JSON
          doc = JSON.parse(response)
          p = doc['profile']
          data = {}
          data[:uid] = p['uid']
          data[:created] = DateTime.parse(p['created'])
          data[:modified] = DateTime.parse(p['modified'])
          data[:name] = p['name']
          data[:path] = p['path']
          # Create profile
          profile = Profile.new(data)
          # Done
          return profile
        else
          # Read XML
          doc = REXML::Document.new(response)
          p = REXML::XPath.first(doc, '/Resources/ProfilesResource/Profile')
          data = {}
          data[:uid] = p.attributes['uid'].to_s
          data[:created] = DateTime.parse(p.attributes['created'].to_s)
          data[:modified] = DateTime.parse(p.attributes['modified'].to_s)
          data[:name] = p.elements['Name'].text || data[:uid]
          data[:path] = p.elements['Path'].text || data[:uid]
          # Create profile
          profile = Profile.new(data)
          # Store connection in profile object
          profile.connection = connection
          # Done
          return profile
        end
      rescue
        raise AMEE::BadData.new("Couldn't create Profile.")
      end

      def self.delete(connection, uid)
        # Deleting profiles takes a while... up the timeout to 60 seconds temporarily
        t = connection.timeout
        connection.timeout = 60
        connection.delete("/profiles/#{uid}")
        connection.timeout = t
      end

    end
  end
end
