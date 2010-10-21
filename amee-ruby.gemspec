require './lib/amee/version.rb'

Gem::Specification.new do |s|
  s.name = "amee"
  s.version = AMEE::VERSION::STRING
  s.date = "2010-10-12"
  s.summary = "Ruby interface to the AMEE carbon calculator"
  s.email = "james@floppy.org.uk"
  s.homepage = "http://github.com/Floppy/amee-ruby"
  s.has_rdoc = true
  s.authors = ["James Smith"]
  s.files = ["README", "COPYING", "CHANGELOG"]
  s.files += ['lib/amee.rb', 'lib/amee/connection.rb', 'lib/amee/data_item.rb',
    'lib/amee/exceptions.rb', 'lib/amee/profile.rb', 'lib/amee/profile_object.rb',
    'lib/amee/profile_category.rb', 'lib/amee/profile_item.rb',
    'lib/amee/profile_item_value.rb', 'lib/amee/version.rb',
    'lib/amee/data_category.rb', 'lib/amee/data_item_value.rb',
    'lib/amee/data_item_value_history.rb', 'lib/amee/data_object.rb',
    'lib/amee/object.rb', 'lib/amee/shell.rb', 'lib/amee/drill_down.rb',
    'lib/amee/rails.rb', 'lib/amee/pager.rb', 'lib/amee/item_definition.rb',
    'lib/amee/item_value_definition.rb','lib/amee/user.rb',
    'lib/amee/collection.rb', 'lib/amee/parse_helper.rb' ,'lib/amee/logger.rb']
  s.files += ['bin/ameesh']
  s.files += ['examples/list_profiles.rb', 'examples/create_profile.rb', 'examples/create_profile_item.rb', 'examples/view_data_category.rb', 'examples/view_data_item.rb']
  s.files += ['init.rb', 'rails/init.rb', 'amee.example.yml', 'cacert.pem']
  s.executables = ['ameesh']
  s.add_dependency("activesupport", "~> 2.3.5")
  s.add_dependency("json")
  s.add_dependency("rspec_spinner")
  s.add_dependency("log4r")
  s.add_dependency("nokogiri", "~> 1.4.3.1")
end
