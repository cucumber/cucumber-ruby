require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'cucumber/ast'
require 'cucumber/step_mother'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module RbSupport
    describe RbStepDefinition do
      before do      
        @step_mother = Cucumber::Runtime.new
        @rb = @step_mother.load_programming_language('rb')
        @dsl = Object.new 
        @dsl.extend Cucumber::RbSupport::RbDsl
        @step_mother.before(mock('scenario').as_null_object)

        $inside = nil
      end
      
      it "should allow calling of other steps" do
        @dsl.Given /Outside/ do
          Given "Inside"
        end
        @dsl.Given /Inside/ do
          $inside = true
        end

        @step_mother.step_match("Outside").invoke(nil)
        $inside.should == true
      end

      it "should allow calling of other steps with inline arg" do
        @dsl.Given /Outside/ do
          Given "Inside", Cucumber::Ast::Table.new([['inside']])
        end
        @dsl.Given /Inside/ do |table|
          $inside = table.raw[0][0]
        end

        @step_mother.step_match("Outside").invoke(nil)
        $inside.should == 'inside'
      end

      it "should raise Undefined when inside step is not defined" do
        @dsl.Given /Outside/ do
          Given 'Inside'
        end

        lambda do
          @step_mother.step_match('Outside').invoke(nil)
        end.should raise_error(Cucumber::Undefined, 'Undefined step: "Inside"')
      end

      it "should allow forced pending" do
        @dsl.Given /Outside/ do
          pending("Do me!")
        end

        lambda do
          @step_mother.step_match("Outside").invoke(nil)
        end.should raise_error(Cucumber::Pending, "Do me!")
      end

      it "should raise ArityMismatchError when the number of capture groups differs from the number of step arguments" do
        @dsl.Given /No group: \w+/ do |arg|
        end

        lambda do
          @step_mother.step_match("No group: arg").invoke(nil)
        end.should raise_error(Cucumber::ArityMismatchError)
      end

      it "should allow announce" do
        v = mock('visitor')
        v.should_receive(:announce).with('wasup')
        @step_mother.visitor = v
        @dsl.Given /Loud/ do
          announce 'wasup'
        end
        
        @step_mother.step_match("Loud").invoke(nil)
      end
      
      it "should recognize $arg style captures" do
        @dsl.Given "capture this: $arg" do |arg|
          arg.should == 'this'
        end

       @step_mother.step_match('capture this: this').invoke(nil)
      end
    end
  end
end
