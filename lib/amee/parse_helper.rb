module ParseHelper
  def x(xpath,options = {})
    doc = options[:doc] || @doc
    preamble = options[:meta] == true ? metaxmlpathpreamble : xmlpathpreamble
    nodes=REXML::XPath.match(doc,"#{preamble}#{xpath}")
    if nodes.length==1
      if nodes.first.respond_to?(:text)
        return nodes.first.text
        elsif nodes.first.respond_to?(:to_s)
          return nodes.first.to_s
      end
    end

    if nodes.length>1
      if nodes.first.respond_to?(:text)
        return nodes.map{|x| x.text}
        elsif nodes.first.respond_to?(:to_s)
          return nodes.map{|x| x.to_s}
      end
    end
    return nil
    
  end
  def xmlpathpreamble
    ''
  end
  private :x

end
