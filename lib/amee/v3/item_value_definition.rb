# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  module Admin
    class ItemValueDefinition
      include MetaHelper

      alias_method :initialize_without_v3, :initialize
      def initialize(data = {})
        storemeta(data[:meta]) if data[:meta]
        initialize_without_v3(data)
      end

      def metapath
        "/#{AMEE::Connection.api_version}/definitions/#{itemdefuid}/values/#{uid};wikiDoc;usages"
      end
      def metaxmlpathpreamble
        '/Representation/ItemValueDefinition/'
      end
      def storemeta(options)
        @meta=OpenStruct.new
        @meta.wikidoc= options[:wikidoc]
        @usages = options[:usages] || []
      end
      def parsemeta
        data = {}
        data[:wikidoc]=x 'WikiDoc', :meta => true
        names = x('Usages/Usage/Name', :meta => true)
        types = x('Usages/Usage/Type', :meta => true)
        data[:usages] = names && types ? Hash[*(names.zip(types.map{|x| x.downcase.to_sym})).flatten] : {}
        storemeta(data)
      end
      def putmeta_args
        str = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ItemValueDefinition>
  <WikiDoc>#{meta.wikidoc}</WikiDoc>
  <Usages>
EOF
        @usages.keys.sort.each do |key|
          str += <<EOF
    <Usage>
      <Name>#{key}</Name>
      <Type>#{@usages[key].to_s.upcase}</Type>
    </Usage>
EOF
        end
        str += <<EOF
  </Usages>
</ItemValueDefinition>
EOF
        {:body => str, :content_type => :xml}
      end
      def usages
        @usages.keys
      end
      def clear_usages!
        @usages = {}
      end
      def set_usage_type(usage, type)
        loadmeta if @usages.nil?
        @usages[usage] = type
      end
      def usage_type(usage)
        loadmeta if @usages.nil?
        @usages[usage] || :optional
      end
      def optional?(usage)
        usage_type(usage) == :optional
      end
      def compulsory?(usage)
        usage_type(usage) == :compulsory
      end
      def forbidden?(usage)
        usage_type(usage) == :forbidden
      end
      def ignored?(usage)
        usage_type(usage) == :ignored
      end
      def default
        return nil if @default.nil?
        case valuetype
        when "DECIMAL", "DOUBLE"
          @default.to_f rescue nil
        else
          @default
        end
      end

      alias_method :expire_cache_without_v3, :expire_cache
      def expire_cache
        @connection.expire_matching("/#{AMEE::Connection.api_version}/definitions/#{itemdefuid}/values/#{uid}.*")
        expire_cache_without_v3
      end
    end
  end
end