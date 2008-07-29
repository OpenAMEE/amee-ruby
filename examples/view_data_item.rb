require 'rubygems'
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
connection = AMEE::Connection.new(options[:server], options[:username], options[:password], false) # Disable JSON support for now

# For each path in arg list, show details
ARGV.each do |path|
  cat = AMEE::Data::Item.get(connection, path)
  puts "---------------------"
  puts "Name: #{cat.name}"
  puts "Path: #{cat.full_path}"
  puts "Label: #{cat.label}"
  puts "UID: #{cat.uid}"
  puts "Values:"
  cat.values.each do |v|
    puts "  - #{v[:name]}: #{v[:value]}"
  end
  
end


