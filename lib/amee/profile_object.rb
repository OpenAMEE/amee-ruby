# Copyright (C) 2008-2013 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

module AMEE
  module Profile
    class Object < AMEE::Object

      def initialize(options = {})
        @profile_uid = options[:profile_uid]
        @profile_date = options[:profile_date]
        super
      end

      attr_reader :profile_uid
      attr_reader :profile_date

      def full_path
        "/profiles#{'/' if @profile_uid}#{@profile_uid}#{@path}"
      end
      
    end
  end
end