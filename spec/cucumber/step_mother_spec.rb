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
      end.should raise_error(Ambiguous, %{Ambiguous match of "Three blind mice":

spec/cucumber/step_mother_spec.rb:23:in `/Three (.*) mice/'
spec/cucumber/step_mother_spec.rb:24:in `/Three blind (.*)/'

})
    end

    it "should not raise Ambiguous error when multiple step definitions match, but --guess is enabled" do
      @step_mother.options = {:guess => true}
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      @step_mother.Given(/Three (.*)/) {|animal|}

      lambda do
        @step_mother.step_definition("Three blind mice")
      end.should_not raise_error
    end
    
    it "should pick right step definition when --guess is enabled and equal number of capture groups" do
      @step_mother.options = {:guess => true}
      right = @step_mother.Given(/Three (.*) mice/) {|disability|}
      wrong = @step_mother.Given(/Three (.*)/) {|animal|}
      @step_mother.step_definition("Three blind mice").should == right
    end
    
    it "should pick right step definition when --guess is enabled and unequal number of capture groups" do
      @step_mother.options = {:guess => true}
      right = @step_mother.Given(/Three (.*) mice ran (.*)/) {|disability|}
      wrong = @step_mother.Given(/Three (.*)/) {|animal|}
      @step_mother.step_definition("Three blind mice ran far").should == right
    end
    
    it "should raise Undefined error when no step definitions match" do
      lambda do
        @step_mother.step_definition("Three blind mice")
      end.should raise_error(Undefined)
    end

    it "should raise Redundant error when same regexp is registered twice" do
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      lambda do
        @step_mother.Given(/Three (.*) mice/) {|disability|}
      end.should raise_error(Redundant)
    end
  end
end
