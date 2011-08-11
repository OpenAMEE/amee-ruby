# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  module Profile
    class ProfileList < Array
      include ParseHelper
      
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
          @doc = load_xml_doc(response)
          @pager = AMEE::Pager.from_xml(@doc.xpath('/Resources/ProfilesResource/Pager').first)
          @doc.xpath('/Resources/ProfilesResource/Profiles/Profile').each do |p|
            data = {}
            data[:uid] = x '@uid', :doc => p
            data[:created] = DateTime.parse(x "@created", :doc => p)
            data[:modified] = DateTime.parse(x "@modified", :doc => p)
            data[:name] = x('Name', :doc => p)
            data[:name] = data[:uid] if data[:name].blank?
            data[:path] = x('Path', :doc => p)
            data[:path] = "/#{data[:uid]}" if data[:path].blank?
            # Create profile
            profile = Profile.new(data)
            # Store connection in profile object
            profile.connection = connection
            # Store in array
            self << profile
          end
        end
      rescue
        raise AMEE::BadData.new("Couldn't load Profile list.\n#{response}")
      end
      
      attr_reader :pager
      
    end

    class Profile < AMEE::Profile::Object

      # backwards compatibility
      def self.list(connection)
        ProfileList.new(connection)
      end

      def self.xmlpathpreamble
        '/Resources/ProfilesResource/Profile/'
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
          data[:path] = "/#{p['path']}"
          # Create profile
          profile = Profile.new(data)
          # Done
          return profile
        else
          # Read XML
          @doc = load_xml_doc(response)
          data = {}
          data[:uid] = x '@uid'
          data[:created] = DateTime.parse(x '@created')
          data[:modified] = DateTime.parse(x '@modified')
          data[:name] = x 'Name'
          data[:name] = data[:uid] if data[:name].blank?
          data[:path] = x 'Path'
          data[:path] = "/#{data[:uid]}" if data[:path].blank?
          # Create profile
          profile = Profile.new(data)
          # Store connection in profile object
          profile.connection = connection
          # Done
          return profile
        end
      rescue
        raise AMEE::BadData.new("Couldn't create Profile.\n#{response}")
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
