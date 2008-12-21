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
      format = @step_mother.format_args("it snows in april", "[%s]")
      format.should == "it [snows] in [april]"
    end

    it "should raise Multiple error when multiple step definitions match" do
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      @step_mother.Given(/Three blind (.*)/) {|animal|}

      lambda do
        @step_mother.execute_step_by_name("Three blind mice", Object.new)
      end.should raise_error(StepMom::Multiple)
    end

    it "should raise Pending error when no step definitions match" do
      lambda do
        @step_mother.execute_step_by_name("Three blind mice", Object.new)
      end.should raise_error(StepMom::Pending)
    end

    it "should raise Duplicate error when same regexp is registered twice" do
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      lambda do
        @step_mother.Given(/Three (.*) mice/) {|disability|}
      end.should raise_error(StepMom::Duplicate)
    end
  end
end