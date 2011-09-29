# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE

  class Config


    # Tries to load defaults from a yaml file, then if there are environment variables
    # present (i.e. if we're using a service like heroku for determine them, or we want to
    # manually override them), uses those values instead
    def self.setup(config = nil, environment = 'test')

      # first try loading the yaml file
      test_config = YAML.load_file(config)[environment] if config

      # then either override, or load in config deets from heroku
      config = {
        :username => ENV['AMEE_USERNAME'],
        :server   => ENV['AMEE_SERVER'],
        :password => ENV['AMEE_PASSWORD']
      }
      config
    end

  end

end

