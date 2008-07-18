require 'rubygems'
require 'amee'

module AMEE
  module Shell
    
    def ls
      "listing contents of #{@@category}"
    end
    
    def pwd
      @@category
    end
    
    def cd(path)
      unless path.match /^\/.*/
        path = @@category + '/' + path
      end
      @@category = path
      @@category
    end
    
    def cat(object)
      "displaying contents of #{@@category}/#{object}"
    end
    
  end
end

include AMEE::Shell
cd '/data'