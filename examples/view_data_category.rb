# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

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
connection = AMEE::Connection.new(options[:server], options[:username], options[:password])

# For each path in arg list, show details
ARGV.each do |path|
  cat = AMEE::Data::Category.get(connection, path)
  puts "---------------------"
  puts "Category: #{cat.name}"
  puts "Path: #{cat.full_path}"
  puts "UID: #{cat.uid}"
  puts "Subcategories:"
  cat.children.each do |c|
    puts "  - #{c[:path]} (#{c[:name]})"
  end
  puts "Items:"
  cat.items.each do |i|
    puts "  - #{i[:path]} (#{i[:label]})"
  end
  
end


