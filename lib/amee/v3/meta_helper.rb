# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'ostruct'

module MetaHelper
  def putmeta(args = {})
    tags=args.delete(:tags)
    args.merge! putmeta_args # Added in order to abstract PUTs away from providing arguments in the call. Eventually args param will be deprecated.
    @connection.v3_put(metapath,args)
    puttags(tags) if tags
    loadmeta
  end
  def puttags(tags)
    existing_tags=AMEE::Tags.new(@connection,:category=>uid)
    existing_tags.reset_to(tags)
  end
  def loadmeta
    resp=@connection.v3_get(metapath)
    @doc=load_xml_doc(resp)
    parsemeta
    @meta
  end
  private :loadmeta
  def meta
    @meta||=loadmeta
  end
end