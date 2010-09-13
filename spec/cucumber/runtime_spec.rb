require 'spec_helper'

module Cucumber
describe Runtime do
  subject { Runtime.new(options) }
  let(:options)     { {} }
  let(:dsl) do
    @rb = subject.load_programming_language('rb')
    Object.new.extend(RbSupport::RbDsl)
  end
  
  it "should format step names" do
    dsl.Given(/it (.*) in (.*)/) { |what, month| }
    dsl.Given(/nope something else/) { |what, month| }
    
    format = subject.step_match("it snows in april").format_args("[%s]")
    format.should == "it [snows] in [april]"
  end

  describe "#features_paths" do
    let(:options) { {:paths => ['foo/bar/baz.feature', 'foo/bar/features/baz.feature', 'other_features'] } }
    it "returns the value from configuration.paths" do
      subject.features_paths.should == options[:paths]
    end
  end
  
  describe "resolving step defintion matches" do

    it "should raise Ambiguous error with guess hint when multiple step definitions match" do
      expected_error = %{Ambiguous match of "Three blind mice":

spec/cucumber/runtime_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/runtime_spec.rb:\\d+:in `/Three blind (.*)/'

You can run again with --guess to make Cucumber be more smart about it
}
      dsl.Given(/Three (.*) mice/) {|disability|}
      dsl.Given(/Three blind (.*)/) {|animal|}

      lambda do
        subject.step_match("Three blind mice")
      end.should raise_error(Ambiguous, /#{expected_error}/)
    end

    describe "when --guess is used" do
      let(:options) { {:guess => true} }

      it "should not show --guess hint" do
        expected_error = %{Ambiguous match of "Three cute mice":

spec/cucumber/runtime_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/runtime_spec.rb:\\d+:in `/Three cute (.*)/'

}
        dsl.Given(/Three (.*) mice/) {|disability|}
        dsl.Given(/Three cute (.*)/) {|animal|}

        lambda do
          subject.step_match("Three cute mice")
        end.should raise_error(Ambiguous, /#{expected_error}/)
      end

      it "should not raise Ambiguous error when multiple step definitions match" do
        dsl.Given(/Three (.*) mice/) {|disability|}
        dsl.Given(/Three (.*)/) {|animal|}

        lambda do
          subject.step_match("Three blind mice")
        end.should_not raise_error
      end

      it "should not raise NoMethodError when guessing from multiple step definitions with nil fields" do
        dsl.Given(/Three (.*) mice( cannot find food)?/) {|disability, is_disastrous|}
        dsl.Given(/Three (.*)?/) {|animal|}

        lambda do
          subject.step_match("Three blind mice")
        end.should_not raise_error
      end

      it "should pick right step definition when an equal number of capture groups" do
        right = dsl.Given(/Three (.*) mice/) {|disability|}
        wrong = dsl.Given(/Three (.*)/) {|animal|}

        subject.step_match("Three blind mice").step_definition.should == right
      end

      it "should pick right step definition when an unequal number of capture groups" do
        right = dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
        wrong = dsl.Given(/Three (.*)/) {|animal|}

        subject.step_match("Three blind mice ran far").step_definition.should == right
      end

      it "should pick most specific step definition when an unequal number of capture groups" do
        general       = dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
        specific      = dsl.Given(/Three blind mice ran far/) do; end
        more_specific = dsl.Given(/^Three blind mice ran far$/) do; end

        subject.step_match("Three blind mice ran far").step_definition.should == more_specific
      end
    end

    it "should raise Undefined error when no step definitions match" do
      lambda do
        subject.step_match("Three blind mice")
      end.should raise_error(Undefined)
    end

    # http://railsforum.com/viewtopic.php?pid=93881
    it "should not raise Redundant unless it's really redundant" do
      dsl.Given(/^(.*) (.*) user named '(.*)'$/) {|a,b,c|}
      dsl.Given(/^there is no (.*) user named '(.*)'$/) {|a,b|}
    end
  end

  describe "Handling the World" do

    it "should raise an error if the world is nil" do
      dsl.World {}

      begin
        subject.before_and_after(nil) do; end
        raise "Should fail"
      rescue RbSupport::NilWorld => e
        e.message.should == "World procs should never return nil"
        e.backtrace.length.should == 1
        e.backtrace[0].should =~ /spec\/cucumber\/runtime_spec\.rb\:\d+\:in `World'/
      end
    end

    module ModuleOne
    end

    module ModuleTwo
    end

    class ClassOne
    end

    it "should implicitly extend world with modules" do
      dsl.World(ModuleOne, ModuleTwo)
      subject.before(mock('scenario').as_null_object)
      class << @rb.current_world
        included_modules.inspect.should =~ /ModuleOne/ # Workaround for RSpec/Ruby 1.9 issue with namespaces
        included_modules.inspect.should =~ /ModuleTwo/
      end
      @rb.current_world.class.should == Object
    end

    it "should raise error when we try to register more than one World proc" do
      expected_error = %{You can only pass a proc to #World once, but it's happening
in 2 places:

spec/cucumber/runtime_spec.rb:\\d+:in `World'
spec/cucumber/runtime_spec.rb:\\d+:in `World'

Use Ruby modules instead to extend your worlds. See the Cucumber::RbSupport::RbDsl#World RDoc
or http://wiki.github.com/aslakhellesoy/cucumber/a-whole-new-world.

}
      dsl.World { Hash.new }
      lambda do
        dsl.World { Array.new }
      end.should raise_error(RbSupport::MultipleWorld, /#{expected_error}/)

    end
  end

  describe "hooks" do

    it "should find before hooks" do
      fish = dsl.Before('@fish'){}
      meat = dsl.Before('@meat'){}

      scenario = mock('Scenario')
      scenario.should_receive(:accept_hook?).with(fish).and_return(true)
      scenario.should_receive(:accept_hook?).with(meat).and_return(false)

      @rb.hooks_for(:before, scenario).should == [fish]
    end

    it "should find around hooks" do
      a = dsl.Around do |scenario, block|
      end

      b = dsl.Around('@tag') do |scenario, block|
      end

      scenario = mock('Scenario')
      scenario.should_receive(:accept_hook?).with(a).and_return(true)
      scenario.should_receive(:accept_hook?).with(b).and_return(false)

      @rb.hooks_for(:around, scenario).should == [a]
    end
  end

  describe "step argument transformations" do

    describe "without capture groups" do
      it "complains when registering with a with no transform block" do
        lambda do
          dsl.Transform('^abc$')
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when registering with a zero-arg transform block" do
        lambda do
          dsl.Transform('^abc$') {42}
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when registering with a splat-arg transform block" do
        lambda do
          dsl.Transform('^abc$') {|*splat| 42 }
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when transforming with an arity mismatch" do
        lambda do
          dsl.Transform('^abc$') {|one, two| 42 }
          @rb.execute_transforms(['abc'])
        end.should raise_error(Cucumber::ArityMismatchError)
      end

      it "allows registering a regexp pattern that yields the step_arg matched" do
        dsl.Transform(/^ab*c$/) {|arg| 42}
        @rb.execute_transforms(['ab']).should == ['ab']
        @rb.execute_transforms(['ac']).should == [42]
        @rb.execute_transforms(['abc']).should == [42]
        @rb.execute_transforms(['abbc']).should == [42]
      end
    end

    describe "with capture groups" do
      it "complains when registering with a with no transform block" do
        lambda do
          dsl.Transform('^a(.)c$')
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when registering with a zero-arg transform block" do
        lambda do
          dsl.Transform('^a(.)c$') { 42 }
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when registering with a splat-arg transform block" do
        lambda do
          dsl.Transform('^a(.)c$') {|*splat| 42 }
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when transforming with an arity mismatch" do
        lambda do
          dsl.Transform('^a(.)c$') {|one, two| 42 }
          @rb.execute_transforms(['abc'])
        end.should raise_error(Cucumber::ArityMismatchError)
      end

      it "allows registering a regexp pattern that yields capture groups" do
        dsl.Transform(/^shape: (.+), color: (.+)$/) do |shape, color|
          {shape.to_sym => color.to_sym}
        end
        @rb.execute_transforms(['shape: circle, color: blue']).should == [{:circle => :blue}]
        @rb.execute_transforms(['shape: square, color: red']).should == [{:square => :red}]
        @rb.execute_transforms(['not shape: square, not color: red']).should == ['not shape: square, not color: red']
      end
    end

    it "allows registering a string pattern" do
      dsl.Transform('^ab*c$') {|arg| 42}
      @rb.execute_transforms(['ab']).should == ['ab']
      @rb.execute_transforms(['ac']).should == [42]
      @rb.execute_transforms(['abc']).should == [42]
      @rb.execute_transforms(['abbc']).should == [42]
    end

    it "gives match priority to transforms defined last" do
      dsl.Transform(/^transform_me$/) {|arg| :foo }
      dsl.Transform(/^transform_me$/) {|arg| :bar }
      dsl.Transform(/^transform_me$/) {|arg| :baz }
      @rb.execute_transforms(['transform_me']).should == [:baz]
    end

    it "allows registering a transform which returns nil" do
      dsl.Transform('^ac$') {|arg| nil}
      @rb.execute_transforms(['ab']).should == ['ab']
      @rb.execute_transforms(['ac']).should == [nil]
    end
  end

end
end