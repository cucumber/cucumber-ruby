require File.dirname(__FILE__) + '/../spec_helper'

require 'cucumber/ast'
require 'cucumber/step_mom'
require 'cucumber/step_definition'

module Cucumber
  describe StepDefinition do
    before do
      extend StepMom
      @world = new_world
      $inside = nil
    end

    it "should allow calling of other steps" do
      Given /Outside/ do
        Given "Inside"
      end
      Given /Inside/ do
        $inside = true
      end

      step_invocation("Outside", @world).invoke
      $inside.should == true
    end

    it "should allow calling of other steps with inline arg" do
      Given /Outside/ do
        Given "Inside", Ast::Table.new([['inside']])
      end
      Given /Inside/ do |table|
        $inside = table.raw[0][0]
      end

      step_invocation("Outside", @world).invoke
      $inside.should == 'inside'
    end

    it "should raise Undefined when inside step is not defined" do
      Given /Outside/ do
        Given "Inside"
      end

      lambda do
        step_invocation("Outside", @world).invoke
      end.should raise_error(StepMom::Undefined, "Inside")
    end

    it "should allow forced pending" do
      Given /Outside/ do
        pending("Do me!")
      end

      lambda do
        step_invocation("Outside", @world).invoke
      end.should raise_error(StepMom::Pending, "Do me!")
    end
  end
end
