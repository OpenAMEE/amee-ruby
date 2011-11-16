# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'amee'
require 'amee/config'
require 'amee/core-extensions/hash'
require 'amee/rails'

# Load config/amee.yml
amee_config = "#{Rails.root}/config/amee.yml"
if File.exist? amee_config
  $AMEE_CONFIG = AMEE::Config.setup(amee_config, Rails.env)
else
  $AMEE_CONFIG = AMEE::Config.setup
end

# Add AMEE extensions into ActiveRecord::Base
ActiveRecord::Base.class_eval { include AMEE::Rails } if Object.const_defined?("ActiveRecord")
