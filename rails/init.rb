require 'amee'
require 'amee/rails'

# Load config/amee.yml
amee_config = "#{RAILS_ROOT}/config/amee.yml"
if File.exist?(amee_config)
  # Load config
  $AMEE_CONFIG = YAML.load_file(amee_config)[RAILS_ENV]
end

# Add AMEE extensions into ActiveRecord::Base
ActiveRecord::Base.class_eval { include AMEE::Rails } if Object.const_defined?("ActiveRecord")
