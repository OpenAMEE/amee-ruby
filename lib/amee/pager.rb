# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  class Pager
    extend ParseHelper

    def initialize(data)
      @start = data[:start]
      @from = data[:from]
      @to = data[:to]
      @items = data[:items]
      @current_page = data[:current_page]
      @requested_page = data[:requested_page]
      @next_page = data[:next_page]
      @previous_page = data[:previous_page]
      @last_page = data[:last_page]
      @items_per_page = data[:items_per_page]
      @items_found = data[:items_found]
    end

    attr_reader :start
    attr_reader :from
    attr_reader :to
    attr_reader :items
    attr_reader :current_page
    attr_reader :requested_page
    attr_reader :next_page
    attr_reader :previous_page
    attr_reader :last_page
    attr_reader :items_per_page
    attr_reader :items_found

    def self.from_xml(node)
      return nil if node.nil? || node.elements.empty?
      return Pager.new({:start => x("Start", :doc => node).to_i,
                        :from => x("From", :doc => node).to_i,
                        :to => x("To", :doc => node).to_i,
                        :items => x("Items", :doc => node).to_i,
                        :current_page => x("CurrentPage", :doc => node).to_i,
                        :requested_page => x("RequestedPage", :doc => node).to_i,
                        :next_page => x("NextPage", :doc => node).to_i,
                        :previous_page => x("PreviousPage", :doc => node).to_i,
                        :last_page => x("LastPage", :doc => node).to_i,
                        :items_per_page => x("ItemsPerPage", :doc => node).to_i,
                        :items_found => x("ItemsFound", :doc => node).to_i})
    end

    def self.from_json(node)
      return nil if node.nil? || node.empty?
      return Pager.new({:start => node["start"],
                        :from => node["from"],
                        :to => node["to"],
                        :items => node["items"],
                        :current_page => node["currentPage"],
                        :requested_page => node["requestedPage"],
                        :next_page => node["nextPage"],
                        :previous_page => node["previousPage"],
                        :last_page => node["lastPage"],
                        :items_per_page => node["itemsPerPage"],
                        :items_found => node["itemsFound"]})
    end
    def more?
      current_page<=last_page
    end
    def next!
      @current_page+=1
      more?
    end
    def page_fragment
      "?page=#{current_page}"
    end
    def options
      {:page => current_page}
    end
  end

  class Limiter
    extend ParseHelper
    def initialize(data)
      @offset=data[:resultStart] || 0
      @limit=data[:resultLimit] || 10
      @truncated=data[:truncated] || false
    end
    attr_reader :offset,:limit,:truncated
    def more?
      truncated
    end
    def next!
      @offset+=limit
      more?
    end
    def page_fragment
      "?resultStart=#{offset}&resultLimit=#{limit}"
    end
    def options
      {:resultStart=>offset,:resultLimit=>limit}
    end
    def self.from_json(doc,options={})
      raise AMEE::NotSupported
    end
    def self.from_xml(node,options={})
      t=x('@truncated',:doc=>node)
      options[:truncated] = (t=='true') if t
      Limiter.new options
    end
  end
end
