module AMEE
  module Rails

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def has_amee_profile(options = {})
        # Include the instance methods for creation and desctruction
        include InstanceMethods
        # Install callbacks
        before_validation_on_create :amee_create
        alias_method_chain :save, :amee
        before_destroy :amee_destroy
        # Check that this object has an AMEE profile UID when saving
        validates_presence_of :amee_profile        
      end
    end

    module InstanceMethods

      def save_with_amee
        save_without_amee && amee_save
      end

      def amee_create
        # Create profile
        profile = AMEE::Profile::Profile.create(amee_connection)
        self.amee_profile = profile.uid
      end

      def amee_save
        # This is only here to be overridden
        return true
      end

      def amee_destroy
        # Delete profile
        AMEE::Profile::Profile.delete(amee_connection, amee_profile)        
      end

      def amee_connection
        # Should be overridden by code which doesn't use the global AMEE connection
        $amee
      end

    end

  end
end
