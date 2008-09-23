Gem::Specification.new do |s|
  s.name = "amee"
  s.version = "0.4.6"
  s.date = "2008-09-23"
  s.summary = "Ruby interface to the AMEE carbon calculator"
  s.email = "james@floppy.org.uk"
  s.homepage = "http://github.com/Floppy/amee-ruby"
  s.has_rdoc = true
  s.authors = ["James Smith"]
  s.files = ["README", "COPYING"] 
  s.files += ['lib/amee.rb', 'lib/amee/connection.rb', 'lib/amee/data_item.rb', 'lib/amee/exceptions.rb', 'lib/amee/profile.rb', 'lib/amee/profile_object.rb', 'lib/amee/profile_category.rb', 'lib/amee/profile_item.rb', 'lib/amee/version.rb', 'lib/amee/data_category.rb', 'lib/amee/data_item_value.rb', 'lib/amee/data_object.rb', 'lib/amee/object.rb', 'lib/amee/shell.rb', 'lib/amee/drill_down.rb']
  s.files += ['bin/ameesh']
  s.files += ['examples/list_profiles.rb', 'examples/create_profile.rb', 'examples/create_profile_item.rb', 'examples/view_data_category.rb', 'examples/view_data_item.rb']
  s.files += ['init.rb', 'rails/init.rb']
  s.executables = ['ameesh']
end
