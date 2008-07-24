module AMEE
  class Profile < AMEE::Object
    
    def self.list(connection)
      # Load data from path
      response = connection.get('/profiles')
      # Parse data from response into hash
      doc = REXML::Document.new(response)
      profiles = []
      REXML::XPath.each(doc, '/Resources/ProfilesResource/Profiles/Profile') do |p|
        data = {}
        data[:uid] = p.attributes['uid'].to_s
        data[:created] = DateTime.parse(p.attributes['created'].to_s)
        data[:modified] = DateTime.parse(p.attributes['modified'].to_s)
        data[:name] = p.elements['Name'].text || data[:uid]
        data[:path] = p.elements['Path'].text || data[:uid]
        # Create profile
        profile = AMEE::Profile.new(data)
        # Store connection in object for future use
        profile.connection = connection
        # Store in array
        profiles << profile
      end
      # Done
      return profiles
    end
    
  end
end