module AMEE
  module Shell
    
    def amee_help
      puts "AMEE shell - version #{AMEE::VERSION::STRING}"
      puts "--------------------------"
      puts "Commands:"
      puts " ls"
      puts "            - display contents of current category."
      puts " cd 'path'"
      puts "            - change category. Path must be a quoted string. You can use things like '/data', '..', or 'subcategory'."
      puts " pwd"
      puts "            - display current category path."
      puts " cat 'name'"
      puts "            - display contents of data item called 'name' within the current category."
      puts " set_value 'item_name', 'value_name', value"
      puts "            - set the value 'value_name' inside 'item_name' to value."
      puts " amee_help"
      puts "            - display this help text."
    end
    
    def ls
      puts "Categories:"
      @@category.children.each do |c|
        puts " - #{c[:path]}"
      end
      puts "Items:"
      @@category.items.each do |i|
        puts " - #{i[:path]} (#{i[:label]})"
      end
      nil
    end
    
    def pwd
      @@category.full_path
    end
    
    def cd(path)
      if path == '..'
        path_components = @@category.full_path.split('/')
        path = path_components.first(path_components.size - 1).join('/')
      elsif !path.match(/^\/.*/)
        path = @@category.full_path + '/' + path
      end
      @@category = AMEE::Data::Category.get($connection, path)
      @@category.full_path
    end
    
    def cat(name)
      item = @@category.items.detect { |i| i[:path].match("^#{name}") }
      fullpath = "#{@@category.full_path}/#{item[:path]}"
      item = AMEE::Data::Item.get($connection, fullpath)
      puts fullpath
      puts "Label: #{item.label}"
      puts "Values:"
      item.values.each do |v|
        puts " - #{v[:name]}: #{v[:value]}"
      end
      nil
    end

    def set_value(item, name, value)
      item = @@category.items.detect { |i| i[:path].match("^#{item}") }
      fullpath = "#{@@category.full_path}/#{item[:path]}/#{name}"
      itemval = AMEE::Data::ItemValue.get($connection, fullpath)
      itemval.value = value
      itemval.save!
    end

  end
end

dir = File.dirname(__FILE__) + "/.."
$LOAD_PATH << dir unless $LOAD_PATH.include?(dir)

require 'rubygems'
require 'amee'
include AMEE::Shell

# Set up connection
$connection = AMEE::Connection.new(ENV['AMEE_SERVER'], ENV['AMEE_USERNAME'], ENV['AMEE_PASSWORD'])

if $connection.valid?
  # Change to root of data api to get going
  cd '/data'
  # Display AMEE details
  amee_help
else
  puts "Can't connect to AMEE - please check details"
end