require File.dirname(__FILE__) + '/../spec_helper'

require 'cucumber/ast'
require 'cucumber/step_mother'
require 'cucumber/step_definition'

module Cucumber
  describe StepDefinition do
    before do
      extend StepMother
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

      step_definition("Outside").execute(nil, @world)
      $inside.should == true
    end

    it "should allow calling of other steps with inline arg" do
      Given /Outside/ do
        Given "Inside", Ast::Table.new([['inside']])
      end
      Given /Inside/ do |table|
        $inside = table.raw[0][0]
      end

      step_definition("Outside").execute(nil, @world)
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
        step_definition('Outside').execute(nil, @world)
      end.should raise_error(Undefined, 'Undefined step: "Inside"')
    end

    it "should allow forced pending" do
      Given /Outside/ do
        pending("Do me!")
      end

      lambda do
        step_definition("Outside").execute(nil, @world)
      end.should raise_error(Pending, "Do me!")
    end
    
    it "should have a #to_s suitable for automcompletion" do
      stepdef = Given /Hello (.*)/ do
      end
      
      stepdef.to_s.should    == '/Hello (.*)/ # spec/cucumber/step_definition_spec.rb:63'
      stepdef.to_s(2).should == '/Hello (.*)/   # spec/cucumber/step_definition_spec.rb:63'
    end
  end
end
