Gem::Specification.new do |s|
  s.name = "amee"
  s.version = "0.1.1"
  s.date = "2008-07-20"
  s.summary = "Ruby interface to the AMEE carbon calculator"
  s.email = "james@floppy.org.uk"
  s.homepage = "http://github.com/Floppy/amee-ruby"
  s.has_rdoc = false
  s.authors = ["James Smith"]
  s.files = ["README", "COPYING", "bin/ameesh", "lib/amee.rb", "lib/amee/connection.rb", "lib/amee/data_category.rb", "lib/amee/data_item.rb", "lib/amee/data_item_value.rb", "lib/amee/exceptions.rb", "lib/amee/object.rb", "lib/amee/shell.rb", "examples/view_data_category.rb", "examples/view_data_item.rb"]
  s.executables = ['ameesh']
end