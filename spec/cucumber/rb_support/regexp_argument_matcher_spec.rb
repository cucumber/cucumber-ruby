require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/rb_support/regexp_argument_matcher'

module Cucumber
  module RbSupport
    describe RegexpArgumentMatcher do
      it "should create 2 arguments" do
        arguments = RegexpArgumentMatcher.arguments_from(/I (\w+) (\w+)/, "I like fish")
        arguments.map{|argument| [argument.val, argument.pos]}.should == [["like", 2], ["fish", 7]]
      end
    end
  end
end
