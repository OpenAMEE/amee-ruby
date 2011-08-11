# Copyright (C) 2008-2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  module Data
    class Object < AMEE::Object

      attr_accessor :path
      def full_path
        "/data#{path}"
      end

    end
  end
end