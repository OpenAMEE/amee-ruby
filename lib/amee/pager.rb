module AMEE
  class Pager

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
      return Pager.new({:start => node.elements["Start"].text.to_i,
                        :from => node.elements["From"].text.to_i,
                        :to => node.elements["To"].text.to_i,
                        :items => node.elements["Items"].text.to_i,
                        :current_page => node.elements["CurrentPage"].text.to_i,
                        :requested_page => node.elements["RequestedPage"].text.to_i,
                        :next_page => node.elements["NextPage"].text.to_i,
                        :previous_page => node.elements["PreviousPage"].text.to_i,
                        :last_page => node.elements["LastPage"].text.to_i,
                        :items_per_page => node.elements["ItemsPerPage"].text.to_i,
                        :items_found => node.elements["ItemsFound"].text.to_i})
    end

    def self.from_json(node)
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

  end
end