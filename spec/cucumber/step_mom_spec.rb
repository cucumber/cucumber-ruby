require File.dirname(__FILE__) + '/../spec_helper'

require 'cucumber/step_mother'

module Cucumber
  describe StepMother do
    before do
      @step_mother = Object.new
      @step_mother.extend(StepMother)
      @visitor = mock('Visitor')
    end

    it "should format step names" do
      @step_mother.Given(/it (.*) in (.*)/) do |what, month|
      end
      @step_mother.Given(/nope something else/) do |what, month|
      end
      format = @step_mother.step_definition("it snows in april").format_args("it snows in april", "[%s]")
      format.should == "it [snows] in [april]"
    end

    it "should raise Ambiguous error when multiple step definitions match" do
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      @step_mother.Given(/Three blind (.*)/) {|animal|}

      lambda do
        @step_mother.step_definition("Three blind mice")
      end.should raise_error(StepMother::Ambiguous, %{Ambiguous match of "Three blind mice":

spec/cucumber/step_mom_spec.rb:23:in `/Three (.*) mice/'
spec/cucumber/step_mom_spec.rb:24:in `/Three blind (.*)/'

})
    end

    it "should raise Undefined error when no step definitions match" do
      lambda do
        @step_mother.step_definition("Three blind mice")
      end.should raise_error(StepMother::Undefined)
    end

    it "should raise Redundant error when same regexp is registered twice" do
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      lambda do
        @step_mother.Given(/Three (.*) mice/) {|disability|}
      end.should raise_error(StepMother::Redundant)
    end
  end
end
