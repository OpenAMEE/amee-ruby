require 'amee'
require 'amee/rails'

# Load config/amee.yml
amee_config = "#{RAILS_ROOT}/config/amee.yml"
if File.exist?(amee_config)
  # Load config
  $AMEE_CONFIG = YAML.load_file(amee_config)[RAILS_ENV]
  # Create a global AMEE connection that we can use from anywhere in this app
  AMEE::Rails.establish_connection($AMEE_CONFIG['server'], $AMEE_CONFIG['username'], $AMEE_CONFIG['password'])
else
  # Create an example AMEE config file and save it to config/amee.yml
  example_config = {}
  example_config['development'] = {'server' => "stage.co2.dgen.net", 'username' => "your_amee_username", 'password' => "your_amee_password"}
  example_config['production'] = {'server' => "stage.co2.dgen.net", 'username' => "your_amee_username", 'password' => "your_amee_password"}
  example_config['test'] = {'server' => "stage.co2.dgen.net", 'username' => "your_amee_username", 'password' => "your_amee_password"}
  File.open(amee_config, 'w') do |out|
   YAML.dump(example_config, out)
  end
  # Inform the user that we've written a file for them
  raise AMEE::ConnectionFailed.new("config/amee.yml doesn't exist. I've created one for you - please add your API keys to it.")
end

# Add AMEE extensions into ActiveRecord::Base
ActiveRecord::Base.class_eval { include AMEE::Rails }
