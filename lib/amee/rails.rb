# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  module Rails

    def self.connection(options = {})
      Connection.global(options)
    end

    class Connection
      def self.global(options = {})
        unless defined?($AMEE_CONFIG)
          amee_config = "#{::Rails.root}/config/amee.yml"
          if File.exist? amee_config
            $AMEE_CONFIG = AMEE::Config.setup(amee_config, ::Rails.env)
          else
            $AMEE_CONFIG = AMEE::Config.setup
          end
        end
        unless @connection
          $AMEE_CONFIG ||= {} # Make default values nil
          if $AMEE_CONFIG[:ssl] == false
            options.merge! :ssl => false
          end
          if $AMEE_CONFIG[:retries]
            options.merge! :retries => $AMEE_CONFIG[:retries].to_i
          end
          if $AMEE_CONFIG[:timeout]
            options.merge! :timeout => $AMEE_CONFIG[:timeout].to_i
          end
          options[:enable_debug]   ||= $AMEE_CONFIG[:debug] if $AMEE_CONFIG[:debug].present?
          @connection = self.connect($AMEE_CONFIG[:server], $AMEE_CONFIG[:username], $AMEE_CONFIG[:password], options)
          # Also store as $amee for backwards compatibility, though this is now deprecated
          $amee = @connection
        end
        @connection
      end
      protected
      def self.connect(server, username, password, options)
        connection = AMEE::Connection.new(server, username, password, options)
        connection.authenticate unless options[:authenticate] == false
        return connection
      end
    end

    def self.included(base)
      base.extend ClassMethods
      AMEE::Logger.to(::Rails.logger) if defined? ::Rails
    end

    module ClassMethods
      def has_amee_profile(options = {})
        # Include the instance methods for creation and desctruction
        include InstanceMethods
        # Install callbacks
        before_validation :amee_create, :on => :create
        after_save :amee_save
        before_destroy :amee_destroy
        # Check that this object has an AMEE profile UID when saving
        validates_presence_of :amee_profile
      end
    end

    module InstanceMethods

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
      rescue
        puts "Couldn't remove profile #{amee_profile}"
      end

      def amee_connection
        # Should be overridden by code which doesn't use the global AMEE connection
        AMEE::Rails.connection
      end

    end

  end
end

if Object.const_defined?("ActionController")
  class ActionController::Base
    def global_amee_connection(options={})
      AMEE::Rails.connection(options)
    end
  end
end
