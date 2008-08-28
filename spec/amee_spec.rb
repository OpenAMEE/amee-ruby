require File.dirname(__FILE__) + '/spec_helper.rb'

describe "AMEE module" do

  it "should cope if json gem isn't available" do
    # Monkeypatch Kernel#require to make sure that require 'json'
    # raises a LoadError
    module Kernel
      def require_with_mock(string)
        raise LoadError.new if string == 'json' 
        require_without_mock(string)
      end
      alias_method :require_without_mock, :require
      alias_method :require, :require_with_mock
    end
    # Remove amee.rb from required file list so we can load it again
    $".delete_if{|x| x.include? 'amee.rb'}
    # Require file - require 'json' should throw a LoadError,
    # but we should cope with it OK.
    lambda {
      require 'amee'
    }.should_not raise_error
  end
  
end