# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

# :title: Class: Hash

class Hash

  # Return a new instance of <i>Hash</i> which represents the same data as
  # <tt>self</tt> but with all keys - including those of sub-hashes - symbolized
  #
  def recursive_symbolize_keys
    new_hash = {}
    self.each_pair do |k,v|
      new_hash[k.to_sym] = value_or_symbolize_value(v)
    end
    new_hash
  end

  private

  # Symbolize any hash key or sub-hash key containing within <tt>value</tt>.
  def value_or_symbolize_value(value)
    if value.is_a? Hash
      return value.recursive_symbolize_keys
    elsif value.is_a? Array
      return value.map { |elem| value_or_symbolize_value(elem) }
    else
      return value
    end
  end

end