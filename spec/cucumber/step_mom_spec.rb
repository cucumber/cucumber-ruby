require File.dirname(__FILE__) + '/../spec_helper'

require 'cucumber/step_mom'

module Cucumber
  describe StepMom do
    before do
      @step_mother = Object.new
      @step_mother.extend(StepMom)
    end
    
    it "should format step names" do
      @step_mother.Given(/it (.*) in (.*)/) do |what, month|
      end
      @step_mother.Given(/nope something else/) do |what, month|
      end
      format = @step_mother.format("it snows in april", "[%s]")
      format.should == "it [snows] in [april]"
    end
  end
end