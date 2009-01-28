dir = File.dirname(__FILE__) + '/../lib'
$LOAD_PATH << dir unless $LOAD_PATH.include?(dir)

#require 'rubygems'
require 'amee'
require 'optparse'

# Command-line options - get username, password, and server
options = {}
OptionParser.new do |opts|
  opts.on("-u", "--username USERNAME", "AMEE username") do |u|
    options[:username] = u
  end  
  opts.on("-p", "--password PASSWORD", "AMEE password") do |p|
    options[:password] = p
  end
  opts.on("-s", "--server SERVER", "AMEE server") do |s|
    options[:server] = s
  end
end.parse!

# Connect
connection = AMEE::Connection.new(options[:server], options[:username], options[:password])

# Create a new profile item
category = AMEE::Profile::Category.get(connection, ARGV[0])
puts "loaded category #{category.name}"
item = AMEE::Profile::Item.create(category, ARGV[1])
if item
  puts "created item in #{category.name} OK"
else
  puts "error creating item in #{category.name}"
end
