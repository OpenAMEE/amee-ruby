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