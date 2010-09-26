require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'cucumber/step_mother'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module RbSupport
    describe RbStepDefinition do
      let(:runtime) { Cucumber::Runtime.new }
      before do      
        @rb = runtime.load_programming_language('rb')
      end

      def unindented(s)
        s.split("\n")[1..-2].join("\n").indent(-10)
      end
    
      it "should recognise numbers in name and make according regexp" do
        @rb.snippet_text('Given', 'Cloud 9 yeah', nil).should == unindented(%{
          Given /^Cloud (\\d+) yeah$/ do |arg1|
            pending # express the regexp above with the code you wish you had
          end
        })
      end

      it "should recognise a mix of ints, strings and why not a table too" do
        @rb.snippet_text('Given', 'I have 9 "awesome" cukes in 37 "boxes"', Cucumber::Ast::Table).should == unindented(%{
          Given /^I have (\\d+) "([^"]*)" cukes in (\\d+) "([^"]*)"$/ do |arg1, arg2, arg3, arg4, table|
            # table is a Cucumber::Ast::Table
            pending # express the regexp above with the code you wish you had
          end
        })
      end

      it "should recognise quotes in name and make according regexp" do
        @rb.snippet_text('Given', 'A "first" arg', nil).should == unindented(%{
          Given /^A "([^"]*)" arg$/ do |arg1|
            pending # express the regexp above with the code you wish you had
          end
        })
      end

      it "should recognise several quoted words in name and make according regexp and args" do
        @rb.snippet_text('Given', 'A "first" and "second" arg', nil).should == unindented(%{
          Given /^A "([^"]*)" and "([^"]*)" arg$/ do |arg1, arg2|
            pending # express the regexp above with the code you wish you had
          end
        })
      end
      
      it "should not use quote group when there are no quotes" do
        @rb.snippet_text('Given', 'A first arg', nil).should == unindented(%{
          Given /^A first arg$/ do
            pending # express the regexp above with the code you wish you had
          end
        })
      end

      it "should be helpful with tables" do
        @rb.snippet_text('Given', 'A "first" arg', Cucumber::Ast::Table).should == unindented(%{
          Given /^A "([^"]*)" arg$/ do |arg1, table|
            # table is a Cucumber::Ast::Table
            pending # express the regexp above with the code you wish you had
          end
        })
      end
      
      describe "#load_code_file" do
        after do
          FileUtils.rm_rf('tmp.rb')
        end
        
        def a_file_called(name)
          File.open('tmp.rb', 'w') do |f|
            f.puts yield
          end
        end
        
        it "re-loads the file when called multiple times" do
          a_file_called('tmp.rb') do
            "$foo = 1"
          end
          
          @rb.load_code_file('tmp.rb')
          $foo.should == 1
          
          a_file_called('tmp.rb') do
            "$foo = 2"
          end
          
          @rb.load_code_file('tmp.rb')
          $foo.should == 2
        end
      end
    end
  end
end