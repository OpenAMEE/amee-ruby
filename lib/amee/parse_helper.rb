module ParseHelper
  def x(xpath,options = {})
    doc = options[:doc] || @doc
    preamble = options[:meta] == true ? metaxmlpathpreamble : xmlpathpreamble
    if doc.is_a?(Nokogiri::XML::Node)
      nodes = doc.xpath("#{preamble}#{xpath}")
    else
      nodes=REXML::XPath.match(doc,"#{preamble}#{xpath}")
    end
    if nodes.length==1
      return node_value(nodes.first)
    elsif nodes.length>1
      return nodes.map{|x| node_value(x)}
    end
    return nil

  end
  
  def node_value(node)
    if node.is_a?(Nokogiri::XML::Attr) || node.is_a?(REXML::Attribute)
      # Attributes are allowed to be an empty string
      return node.to_s
    else
      return node.text == '' ? nil : node.text
    end
  end

  def xmlpathpreamble
    ''
  end
  def load_xml_doc(xml)
    doc = Nokogiri.XML(xml)
    doc.remove_namespaces!
    doc
  end
  private :x

end