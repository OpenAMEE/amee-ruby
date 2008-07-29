require 'lib/amee/version'

Gem::Specification.new do |s|
  s.name = "amee"
  s.version = AMEE::VERSION::STRING
  s.date = AMEE::VERSION::DATE
  s.summary = "Ruby interface to the AMEE carbon calculator"
  s.email = "james@floppy.org.uk"
  s.homepage = "http://github.com/Floppy/amee-ruby"
  s.has_rdoc = false
  s.authors = ["James Smith"]
  s.files = ["README", "COPYING"] + Dir['lib/**/*'] + Dir['bin/**/*'] + Dir['examples/**/*']
  s.executables = ['ameesh']
end