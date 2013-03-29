require 'spec_helper'
require 'cucumber/rb_support/snippet'

module Cucumber
  module RbSupport
    describe Snippet do

      let(:code_keyword) { "Given" }

      before do
        @pattern = 'we have a missing step'
        @multiline_argument_class = nil
      end

      let(:snippet) do
        snippet_class.new(code_keyword, @pattern, @multiline_argument_class)
      end

      def unindented(s)
        s.split("\n")[1..-2].join("\n").indent(-10)
      end

      describe Snippet::Regexp do
        let(:snippet_class) { Snippet::Regexp }
        let(:snippet_text) { snippet.to_s }

        it "should wrap snippet patterns in parentheses" do
          @pattern = 'A "string" with 4 spaces'

          snippet_text.should == unindented(%{
          Given(/^A "(.*?)" with (\\d+) spaces$/) do |arg1, arg2|
            pending # express the regexp above with the code you wish you had
          end
          })
        end

        it "should recognise numbers in name and make according regexp" do
          @pattern = 'Cloud 9 yeah'

          snippet_text.should == unindented(%{
          Given(/^Cloud (\\d+) yeah$/) do |arg1|
            pending # express the regexp above with the code you wish you had
          end
          })
        end

        it "should recognise a mix of ints, strings and why not a table too" do
          @pattern = 'I have 9 "awesome" cukes in 37 "boxes"'
          @multiline_argument_class = Cucumber::Ast::Table

          snippet_text.should == unindented(%{
          Given(/^I have (\\d+) "(.*?)" cukes in (\\d+) "(.*?)"$/) do |arg1, arg2, arg3, arg4, table|
            # table is a Cucumber::Ast::Table
            pending # express the regexp above with the code you wish you had
          end
          })
        end

        it "should recognise quotes in name and make according regexp" do
          @pattern = 'A "first" arg'

          snippet_text.should == unindented(%{
          Given(/^A "(.*?)" arg$/) do |arg1|
            pending # express the regexp above with the code you wish you had
          end
          })
        end

        it "should recognise several quoted words in name and make according regexp and args" do
          @pattern = 'A "first" and "second" arg'

          snippet_text.should == unindented(%{
          Given(/^A "(.*?)" and "(.*?)" arg$/) do |arg1, arg2|
            pending # express the regexp above with the code you wish you had
          end
          })
        end

        it "should not use quote group when there are no quotes" do
          @pattern = 'A first arg'

          snippet_text.should == unindented(%{
          Given(/^A first arg$/) do
            pending # express the regexp above with the code you wish you had
          end
          })
        end

        it "should be helpful with tables" do
          @pattern = 'A "first" arg'
          @multiline_argument_class = Cucumber::Ast::Table

          snippet_text.should == unindented(%{
          Given(/^A "(.*?)" arg$/) do |arg1, table|
            # table is a Cucumber::Ast::Table
            pending # express the regexp above with the code you wish you had
          end
          })
        end
      end

      describe Snippet::Classic do
        let(:snippet_class) { Snippet::Classic }

        it "renders snippet as unwrapped regular expression" do
          snippet.to_s.should eql unindented(%{
          Given /^we have a missing step$/ do
            pending # express the regexp above with the code you wish you had
          end
          })
        end
      end

      describe Snippet::Percent do
        let(:snippet_class) { Snippet::Percent }

        it "renders snippet as percent-style regular expression" do
          snippet.to_s.should eql unindented(%{
          Given %r{^we have a missing step$} do
            pending # express the regexp above with the code you wish you had
          end
          })
        end
      end

    end
  end
end
