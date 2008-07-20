require 'rake'

Gem::Specification.new do |s|
  s.name = "amee"
  s.version = "0.1.1"
  s.date = "2008-07-20"
  s.summary = "Ruby interface to the AMEE carbon calculator"
  s.email = "james@floppy.org.uk"
  s.homepage = "http://github.com/Floppy/amee-ruby"
  s.has_rdoc = false
  s.authors = ["James Smith"]
  s.files = FileList["README", "COPYING", "bin/*", "lib/**/*.rb", "examples/*.rb"]
  s.executables = ['ameesh']
end