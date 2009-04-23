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
      format = @step_mother.step_match("it snows in april").format_args("[%s]")
      format.should == "it [snows] in [april]"
    end

    it "should raise Ambiguous error with guess hint when multiple step definitions match" do
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      @step_mother.Given(/Three blind (.*)/) {|animal|}

      lambda do
        @step_mother.step_match("Three blind mice")
      end.should raise_error(Ambiguous, %{Ambiguous match of "Three blind mice":

spec/cucumber/step_mother_spec.rb:23:in `/Three (.*) mice/'
spec/cucumber/step_mother_spec.rb:24:in `/Three blind (.*)/'

You can run again with --guess to make Cucumber be more smart about it
})
    end

    it "should not show --guess hint when --guess is used" do
      @step_mother.options = {:guess => true}
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      @step_mother.Given(/Three cute (.*)/) {|animal|}

      lambda do
        @step_mother.step_match("Three cute mice")
      end.should raise_error(Ambiguous, %{Ambiguous match of "Three cute mice":

spec/cucumber/step_mother_spec.rb:39:in `/Three (.*) mice/'
spec/cucumber/step_mother_spec.rb:40:in `/Three cute (.*)/'

})
    end

    it "should not raise Ambiguous error when multiple step definitions match, but --guess is enabled" do
      @step_mother.options = {:guess => true}
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      @step_mother.Given(/Three (.*)/) {|animal|}

      lambda do
        @step_mother.step_match("Three blind mice")
      end.should_not raise_error
    end
    
    it "should pick right step definition when --guess is enabled and equal number of capture groups" do
      @step_mother.options = {:guess => true}
      right = @step_mother.Given(/Three (.*) mice/) {|disability|}
      wrong = @step_mother.Given(/Three (.*)/) {|animal|}
      @step_mother.step_match("Three blind mice").step_definition.should == right
    end
    
    it "should pick right step definition when --guess is enabled and unequal number of capture groups" do
      @step_mother.options = {:guess => true}
      right = @step_mother.Given(/Three (.*) mice ran (.*)/) {|disability|}
      wrong = @step_mother.Given(/Three (.*)/) {|animal|}
      @step_mother.step_match("Three blind mice ran far").step_definition.should == right
    end
    
    it "should raise Undefined error when no step definitions match" do
      lambda do
        @step_mother.step_match("Three blind mice")
      end.should raise_error(Undefined)
    end

    it "should raise Redundant error when same regexp is registered twice" do
      @step_mother.Given(/Three (.*) mice/) {|disability|}
      lambda do
        @step_mother.Given(/Three (.*) mice/) {|disability|}
      end.should raise_error(Redundant)
    end

    # http://railsforum.com/viewtopic.php?pid=93881
    it "should not raise Redundant unless it's really redundant" do
      @step_mother.Given(/^(.*) (.*) user named '(.*)'$/) {|a,b,c|}
      @step_mother.Given(/^there is no (.*) user named '(.*)'$/) {|a,b|}
    end

    it "should raise an error if the world is nil" do
      @step_mother.World do
      end

      begin
        @step_mother.before_and_after(nil) {}
        raise "Should fail"
      rescue NilWorld => e
        e.message.should == "World procs should never return nil"
        e.backtrace.should == ["spec/cucumber/step_mother_spec.rb:96:in `World'"]
      end
    end

    module ModuleOne
    end

    module ModuleTwo
    end

    class ClassOne
    end

    it "should implicitly extend world with modules" do
      @step_mother.World(ModuleOne, ModuleTwo)

      w = @step_mother.__send__(:new_world!)
      class << w
        included_modules.index(ModuleOne).should_not == nil
        included_modules.index(ModuleTwo).should_not == nil
      end
      w.class.should == Object
    end

    it "should raise error when we try to register more than one World proc" do
      @step_mother.World { Hash.new }
      lambda do
        @step_mother.World { Array.new }
      end.should raise_error(MultipleWorld, %{You can only pass a proc to #World once, but it's happening
in 2 places:

spec/cucumber/step_mother_spec.rb:129:in `World'
spec/cucumber/step_mother_spec.rb:131:in `World'

Use Ruby modules instead to extend your worlds. See the Cucumber::StepMother#World RDoc
or http://wiki.github.com/aslakhellesoy/cucumber/a-whole-new-world.

})
    end

    it "should find before hooks" do
      fish = @step_mother.Before('@fish'){}
      meat = @step_mother.Before('@meat'){}
      
      scenario = mock('Scenario')
      scenario.should_receive(:accept_hook?).with(fish).and_return(true)
      scenario.should_receive(:accept_hook?).with(meat).and_return(false)
      
      @step_mother.hooks_for(:before, scenario).should == [fish]
    end
  end
end
