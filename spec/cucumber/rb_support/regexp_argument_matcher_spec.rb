require 'spec_helper'
require 'cucumber/rb_support/regexp_argument_matcher'

module Cucumber
  module RbSupport
    describe RegexpArgumentMatcher do
      include RSpec::WorkInProgress

      it "creates 2 arguments" do
        arguments = RegexpArgumentMatcher.arguments_from(/I (\w+) (\w+)/, "I like fish")

        expect(arguments.map{|argument| [argument.val, argument.offset]}).to eq [["like", 2], ["fish", 7]]
      end

      it "creates 2 arguments when first group is optional" do
        arguments = RegexpArgumentMatcher.arguments_from(/should( not)? be flashed '([^']*?)'$/, "I should be flashed 'Login failed.'")

        expect(arguments.map{|argument| [argument.val, argument.offset]}).to eq [[nil, nil], ["Login failed.", 21]]
      end
    end
  end
end
