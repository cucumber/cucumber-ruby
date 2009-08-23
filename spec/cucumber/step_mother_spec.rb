require File.dirname(__FILE__) + '/../spec_helper'

require 'cucumber'
require 'cucumber/rb_support/rb_language'

module Cucumber
  describe StepMother do
    before do
      @dsl = Object.new
      @dsl.extend(RbSupport::RbDsl)

      @step_mother = StepMother.new
      @step_mother.load_natural_language('en')
      @rb = @step_mother.load_programming_language('rb')

      @visitor = mock('Visitor')
    end

    def register
      @step_mother.register_step_definitions(@rb.step_definitions)
    end

    it "should format step names" do
      @dsl.Given(/it (.*) in (.*)/) do |what, month|
      end
      @dsl.Given(/nope something else/) do |what, month|
      end
      register
      
      format = @step_mother.step_match("it snows in april").format_args("[%s]")
      format.should == "it [snows] in [april]"
    end

    it "should raise Ambiguous error with guess hint when multiple step definitions match" do
      @dsl.Given(/Three (.*) mice/) {|disability|}
      @dsl.Given(/Three blind (.*)/) {|animal|}
      register

      lambda do
        @step_mother.step_match("Three blind mice")
      end.should raise_error(Ambiguous, %{Ambiguous match of "Three blind mice":

spec/cucumber/step_mother_spec.rb:35:in `/Three (.*) mice/'
spec/cucumber/step_mother_spec.rb:36:in `/Three blind (.*)/'

You can run again with --guess to make Cucumber be more smart about it
})
    end

    it "should not show --guess hint when --guess is used" do
      @step_mother.options = {:guess => true}

      @dsl.Given(/Three (.*) mice/) {|disability|}
      @dsl.Given(/Three cute (.*)/) {|animal|}
      register

      lambda do
        @step_mother.step_match("Three cute mice")
      end.should raise_error(Ambiguous, %{Ambiguous match of "Three cute mice":

spec/cucumber/step_mother_spec.rb:53:in `/Three (.*) mice/'
spec/cucumber/step_mother_spec.rb:54:in `/Three cute (.*)/'

})
    end

    it "should not raise Ambiguous error when multiple step definitions match, but --guess is enabled" do
      @step_mother.options = {:guess => true}
      @dsl.Given(/Three (.*) mice/) {|disability|}
      @dsl.Given(/Three (.*)/) {|animal|}
      register

      lambda do
        @step_mother.step_match("Three blind mice")
      end.should_not raise_error
    end
    
    it "should pick right step definition when --guess is enabled and equal number of capture groups" do
      @step_mother.options = {:guess => true}
      right = @dsl.Given(/Three (.*) mice/) {|disability|}
      wrong = @dsl.Given(/Three (.*)/) {|animal|}
      register

      @step_mother.step_match("Three blind mice").step_definition.should == right
    end
    
    it "should pick right step definition when --guess is enabled and unequal number of capture groups" do
      @step_mother.options = {:guess => true}
      right = @dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
      wrong = @dsl.Given(/Three (.*)/) {|animal|}
      register

      @step_mother.step_match("Three blind mice ran far").step_definition.should == right
    end

    it "should pick most specific step definition when --guess is enabled and unequal number of capture groups" do
      @step_mother.options = {:guess => true}
      general       = @dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
      specific      = @dsl.Given(/Three blind mice ran far/) {}
      more_specific = @dsl.Given(/^Three blind mice ran far$/) {}
      register

      @step_mother.step_match("Three blind mice ran far").step_definition.should == more_specific
    end
    
    it "should raise Undefined error when no step definitions match" do
      lambda do
        @step_mother.step_match("Three blind mice")
      end.should raise_error(Undefined)
    end

    it "should raise Redundant error when same regexp is registered twice" do
      @dsl.Given(/Three (.*) mice/) {|disability|}
      lambda do
        @dsl.Given(/Three (.*) mice/) {|disability|}
        register
      end.should raise_error(Redundant)
    end

    # http://railsforum.com/viewtopic.php?pid=93881
    it "should not raise Redundant unless it's really redundant" do
      @dsl.Given(/^(.*) (.*) user named '(.*)'$/) {|a,b,c|}
      @dsl.Given(/^there is no (.*) user named '(.*)'$/) {|a,b|}
      register
    end

    it "should raise an error if the world is nil" do
      @dsl.World do
      end

      begin
        @step_mother.before_and_after(nil) {}
        raise "Should fail"
      rescue RbSupport::NilWorld => e
        e.message.should == "World procs should never return nil"
        e.backtrace.should == ["spec/cucumber/step_mother_spec.rb:128:in `World'"]
      end
    end

    module ModuleOne
    end

    module ModuleTwo
    end

    class ClassOne
    end

    it "should implicitly extend world with modules" do
      @dsl.World(ModuleOne, ModuleTwo)
      @step_mother.before(nil)
      class << @rb.current_world
        included_modules.index(ModuleOne).should_not == nil
        included_modules.index(ModuleTwo).should_not == nil
      end
      @rb.current_world.class.should == Object
    end

    it "should raise error when we try to register more than one World proc" do
      @dsl.World { Hash.new }
      lambda do
        @dsl.World { Array.new }
      end.should raise_error(RbSupport::MultipleWorld, %{You can only pass a proc to #World once, but it's happening
in 2 places:

spec/cucumber/step_mother_spec.rb:160:in `World'
spec/cucumber/step_mother_spec.rb:162:in `World'

Use Ruby modules instead to extend your worlds. See the Cucumber::RbSupport::RbDsl#World RDoc
or http://wiki.github.com/aslakhellesoy/cucumber/a-whole-new-world.

})
    end

    it "should find before hooks" do
      fish = @dsl.Before('@fish'){}
      meat = @dsl.Before('@meat'){}
      register
      
      scenario = mock('Scenario')
      scenario.should_receive(:accept_hook?).with(fish).and_return(true)
      scenario.should_receive(:accept_hook?).with(meat).and_return(false)
      
      @rb.hooks_for(:before, scenario).should == [fish]
    end
  end
end
