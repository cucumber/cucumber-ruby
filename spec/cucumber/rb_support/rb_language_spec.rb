require 'spec_helper'
require 'cucumber/step_mother'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module RbSupport
    describe RbStepDefinition do
      let(:user_interface) { double('user interface') }
      let(:rb)             { support_code.load_programming_language('rb')}
      let(:support_code) do
        Cucumber::Runtime::SupportCode.new(user_interface, {})
      end
      let(:dsl) do
        rb
        Object.new.extend(RbSupport::RbDsl)
      end

      describe "snippets" do
        let(:snippet) { double.as_null_object }

        it "creates a regexp Snippet class by default" do
          Snippet::Regexp.should_receive(:new).and_return(snippet)
          rb.snippet_text('Given', 'A "string" with 4 spaces', nil)
        end

        it "creates a regexp Snippet class explicitly" do
          Snippet::Regexp.should_receive(:new).and_return(snippet)
          rb.snippet_text('Given', 'A "string" with 4 spaces', nil, :regexp)
        end

        it "creates a classic Snippet class" do
          Snippet::Classic.should_receive(:new).and_return(snippet)
          rb.snippet_text('Given', 'A "string" with 4 spaces', nil, :classic)
        end

        it "creates a percent Snippet class" do
          Snippet::Percent.should_receive(:new).and_return(snippet)
          rb.snippet_text('Given', 'A "string" with 4 spaces', nil, :percent)
        end

        it "passes all parameters to Snippet contructor" do
          code_keyword, pattern, multiline_argument_class = double, double, double
          Snippet::Regexp.should_receive(:new).with(code_keyword, pattern, multiline_argument_class)
          rb.snippet_text(code_keyword, pattern, multiline_argument_class)
        end

        it "renders the snippet" do
          Snippet::Regexp.stub(:new => snippet)
          snippet.should_receive(:to_s)
          rb.snippet_text('Given', 'A "string" with 4 spaces', nil)
        end

      end

      describe "#load_code_file" do
        after do
          FileUtils.rm_rf('tmp.rb')
        end

        def a_file_called(name)
          File.open('tmp.rb', 'w') do |f|
            f.puts yield
          end
        end

        it "re-loads the file when called multiple times" do
          a_file_called('tmp.rb') do
            "$foo = 1"
          end

          rb.load_code_file('tmp.rb')
          $foo.should == 1

          a_file_called('tmp.rb') do
            "$foo = 2"
          end

          rb.load_code_file('tmp.rb')
          $foo.should == 2
        end
      end

      describe "Handling the World" do

        it "should raise an error if the world is nil" do
          dsl.World {}

          begin
            rb.before(nil)
            raise "Should fail"
          rescue RbSupport::NilWorld => e
            e.message.should == "World procs should never return nil"
            e.backtrace.length.should == 1
            e.backtrace[0].should =~ /spec\/cucumber\/rb_support\/rb_language_spec\.rb\:\d+\:in `World'/
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
          rb.before(double('scenario').as_null_object)
          class << rb.current_world
            included_modules.inspect.should =~ /ModuleOne/ # Workaround for RSpec/Ruby 1.9 issue with namespaces
            included_modules.inspect.should =~ /ModuleTwo/
          end
          rb.current_world.class.should == Object
        end

        it "should raise error when we try to register more than one World proc" do
          expected_error = %{You can only pass a proc to #World once, but it's happening
in 2 places:

spec/cucumber/rb_support/rb_language_spec.rb:\\d+:in `World'
spec/cucumber/rb_support/rb_language_spec.rb:\\d+:in `World'

Use Ruby modules instead to extend your worlds. See the Cucumber::RbSupport::RbDsl#World RDoc
or http://wiki.github.com/cucumber/cucumber/a-whole-new-world.

}
          dsl.World { Hash.new }
          lambda do
            dsl.World { Array.new }
          end.should raise_error(RbSupport::MultipleWorld, /#{expected_error}/)

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
              rb.execute_transforms(['abc'])
            end.should raise_error(Cucumber::ArityMismatchError)
          end

          it "allows registering a regexp pattern that yields the step_arg matched" do
            dsl.Transform(/^ab*c$/) {|arg| 42}
            rb.execute_transforms(['ab']).should == ['ab']
            rb.execute_transforms(['ac']).should == [42]
            rb.execute_transforms(['abc']).should == [42]
            rb.execute_transforms(['abbc']).should == [42]
          end

          it "transforms times" do
            require 'time'
            dsl.Transform(/^(\d\d-\d\d-\d\d\d\d)$/) do |arg|
              Time.parse(arg)
            end
            rb.execute_transforms(['10-0E-1971']).should == ['10-0E-1971']
            rb.execute_transforms(['10-03-1971']).should == [Time.parse('10-03-1971')]
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
              rb.execute_transforms(['abc'])
            end.should raise_error(Cucumber::ArityMismatchError)
          end

          it "allows registering a regexp pattern that yields capture groups" do
            dsl.Transform(/^shape: (.+), color: (.+)$/) do |shape, color|
              {shape.to_sym => color.to_sym}
            end
            rb.execute_transforms(['shape: circle, color: blue']).should == [{:circle => :blue}]
            rb.execute_transforms(['shape: square, color: red']).should == [{:square => :red}]
            rb.execute_transforms(['not shape: square, not color: red']).should == ['not shape: square, not color: red']
          end
        end

        it "allows registering a string pattern" do
          dsl.Transform('^ab*c$') {|arg| 42}
          rb.execute_transforms(['ab']).should == ['ab']
          rb.execute_transforms(['ac']).should == [42]
          rb.execute_transforms(['abc']).should == [42]
          rb.execute_transforms(['abbc']).should == [42]
        end

        it "gives match priority to transforms defined last" do
          dsl.Transform(/^transform_me$/) {|arg| :foo }
          dsl.Transform(/^transform_me$/) {|arg| :bar }
          dsl.Transform(/^transform_me$/) {|arg| :baz }
          rb.execute_transforms(['transform_me']).should == [:baz]
        end

        it "allows registering a transform which returns nil" do
          dsl.Transform('^ac$') {|arg| nil}
          rb.execute_transforms(['ab']).should == ['ab']
          rb.execute_transforms(['ac']).should == [nil]
        end
      end

      describe "hooks" do

        it "should find before hooks" do
          fish = dsl.Before('@fish'){}
          meat = dsl.Before('@meat'){}

          scenario = double('Scenario')
          scenario.should_receive(:accept_hook?).with(fish).and_return(true)
          scenario.should_receive(:accept_hook?).with(meat).and_return(false)

          rb.hooks_for(:before, scenario).should == [fish]
        end

        it "should find around hooks" do
          a = dsl.Around do |scenario, block|
          end

          b = dsl.Around('@tag') do |scenario, block|
          end

          scenario = double('Scenario')
          scenario.should_receive(:accept_hook?).with(a).and_return(true)
          scenario.should_receive(:accept_hook?).with(b).and_return(false)

          rb.hooks_for(:around, scenario).should == [a]
        end
      end

    end
  end
end
