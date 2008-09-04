module AMEE
  module Profile
    class Item < AMEE::Profile::Object

      def self.create(profile, data_item_uid, options = {})
        # Send data to path
        options.merge! :dataItemUid => data_item_uid
        profile.connection.post(profile.full_path, options)
      rescue
        raise AMEE::BadData.new("Couldn't create ProfileItem. Check that your information is correct.")
      end

    end
  end
end
