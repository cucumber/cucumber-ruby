require File.dirname(__FILE__) + '/../spec_helper'

require 'cucumber/ast'
require 'cucumber/step_mother'
require 'cucumber/step_definition'

module Cucumber
  describe StepDefinition do
    before do
      extend StepMother
      @world = new_world!
      $inside = nil
    end

    it "should allow calling of other steps" do
      Given /Outside/ do
        Given "Inside"
      end
      Given /Inside/ do
        $inside = true
      end

      step_match("Outside").invoke(@world, nil)
      $inside.should == true
    end

    it "should allow calling of other steps with inline arg" do
      Given /Outside/ do
        Given "Inside", Ast::Table.new([['inside']])
      end
      Given /Inside/ do |table|
        $inside = table.raw[0][0]
      end

      step_match("Outside").invoke(@world, nil)
      $inside.should == 'inside'
    end

    it "should raise Undefined when inside step is not defined" do
      Given /Outside/ do
        Given 'Inside'
      end

      step = mock('Step')
      step.should_receive(:exception=)
      lambda do
        @world.__cucumber_current_step = step
        step_match('Outside').invoke(@world, nil)
      end.should raise_error(Undefined, 'Undefined step: "Inside"')
    end

    it "should allow forced pending" do
      Given /Outside/ do
        pending("Do me!")
      end

      lambda do
        step_match("Outside").invoke(@world, nil)
      end.should raise_error(Pending, "Do me!")
    end

    it "should allow announce" do
      v = mock('visitor')
      v.should_receive(:announce).with('wasup')
      self.visitor = v
      world = new_world!
      Given /Loud/ do
        announce 'wasup'
      end
      step_match("Loud").invoke(world, nil)
    end
    
    def unindented(s)
      s.split("\n")[1..-2].join("\n").indent(-8)
    end
    
    it "should recognise quotes in name and make according regexp" do
      StepDefinition.snippet_text('Given', 'A "first" arg').should == unindented(%{
        Given /^A "([^\\"]*)" arg$/ do |arg1|
          pending
        end
      })
    end

    it "should recognise several quoted words in name and make according regexp and args" do
      StepDefinition.snippet_text('Given', 'A "first" and "second" arg').should == unindented(%{
        Given /^A "([^\\"]*)" and "([^\\"]*)" arg$/ do |arg1, arg2|
          pending
        end
      })
    end

    it "should not use quote group when there are no quotes" do
      StepDefinition.snippet_text('Given', 'A first arg').should == unindented(%{
        Given /^A first arg$/ do
          pending
        end
      })
    end
  end
end
