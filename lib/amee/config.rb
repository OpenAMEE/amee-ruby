# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE

  class Config


    # Tries to load defaults from a yaml file, then if there are environment variables
    # present (i.e. if we're using a service like heroku for determine them, or we want to
    # manually override them), uses those values instead
    def self.setup(amee_config_file = nil, environment = 'test')

      if amee_config_file
        # first try loading the yaml file
        yaml_config = YAML.load_file(amee_config_file)
        config = yaml_config[environment]

        # make config[:username] possible instead of just config['username']
        config.recursive_symbolize_keys!
      else
        config = {}
      end
      
        # then either override, or load in config deets from heroku
      config[:username] = ENV['AMEE_USERNAME'] if ENV['AMEE_USERNAME']
      config[:server]   = ENV['AMEE_SERVER'] if ENV['AMEE_SERVER']
      config[:password] = ENV['AMEE_PASSWORD'] if ENV['AMEE_PASSWORD']

      return config

    end

  end

end

