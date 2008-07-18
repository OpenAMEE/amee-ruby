module AMEE
  module Shell
    
    def amee_help
      puts "AMEE shell - version #{AMEE::VERSION::STRING}"
      puts "--------------------------"
      puts "Commands:"
      puts " ls         - display contents of current category."
      puts " cd 'path'  - change category. Path must be a quoted string. You can use things like '/data', '..', or 'subcategory'."
      puts " pwd        - display current category path."
      puts " cat 'name' - display contents of data item called 'name' within the current category."
      puts " amee_help  - display this help text."
    end
    
    def ls
      "listing contents of #{@@category}"
    end
    
    def pwd
      @@category
    end
    
    def cd(path)
      if path == '..'
        path_components = @@category.split('/')
        path = path_components.first(path_components.size - 1).join('/')
      elsif !path.match /^\/.*/
        path = @@category + '/' + path
      end
      @@category = path
    end
    
    def cat(object)
      "displaying contents of #{@@category}/#{object}"
    end
    
  end
end

require 'amee'
require 'optparse'
include AMEE::Shell

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

if connection.valid?
  # Change to root of data api to get going
  cd '/data'
  # Display AMEE details
  amee_help  
else
  puts "Can't connect to AMEE - please check details"
end