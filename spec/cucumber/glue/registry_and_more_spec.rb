# frozen_string_literal: true
require 'spec_helper'
require 'cucumber/glue/registry_and_more'

module Cucumber
  module Glue
    describe StepDefinition do
      let(:user_interface) { double('user interface') }
      let(:registry)       { support_code.registry }
      let(:support_code) do
        Cucumber::Runtime::SupportCode.new(user_interface)
      end
      let(:dsl) do
        registry
        Object.new.extend(Glue::Dsl)
      end

      describe '#load_code_file' do
        after do
          FileUtils.rm_rf('tmp.rb')
          FileUtils.rm_rf('docs.md')
        end

        def a_file_called(name)
          File.open(name, 'w') do |f|
            f.puts yield
          end
        end

        it 're-loads the file when called multiple times' do
          a_file_called('tmp.rb') do
            '$foo = 1'
          end

          registry.load_code_file('tmp.rb')
          expect($foo).to eq 1

          a_file_called('tmp.rb') do
            '$foo = 2'
          end

          registry.load_code_file('tmp.rb')

          expect($foo).to eq 2
        end

        it 'only loads ruby files' do
          a_file_called('docs.md') do
            'yo'
          end
          registry.load_code_file('docs.md')
        end
      end

      describe 'Handling the World' do
        it 'raises an error if the world is nil' do
          dsl.World {}

          begin
            registry.begin_scenario(nil)
            raise 'Should fail'
          rescue Glue::NilWorld => e
            expect(e.message).to eq 'World procs should never return nil'
            expect(e.backtrace.length).to eq 1
            expect(e.backtrace[0]).to match(/spec\/cucumber\/glue\/registry_and_more_spec\.rb\:\d+\:in `World'/)
          end
        end

        module ModuleOne
        end

        module ModuleTwo
        end

        class ClassOne
        end

        it 'implicitlys extend world with modules' do
          dsl.World(ModuleOne, ModuleTwo)
          registry.begin_scenario(double('scenario').as_null_object)
          class << registry.current_world
            extend RSpec::Matchers

            expect(included_modules.inspect).to match(/ModuleOne/) # Workaround for RSpec/Ruby 1.9 issue with namespaces
            expect(included_modules.inspect).to match(/ModuleTwo/)
          end
          expect(registry.current_world.class).to eq Object
        end

        it 'raises error when we try to register more than one World proc' do
          expected_error = %{You can only pass a proc to #World once, but it's happening
in 2 places:

spec/cucumber/glue/registry_and_more_spec.rb:\\d+:in `World'
spec/cucumber/glue/registry_and_more_spec.rb:\\d+:in `World'

Use Ruby modules instead to extend your worlds. See the Cucumber::Glue::Dsl#World RDoc
or http://wiki.github.com/cucumber/cucumber/a-whole-new-world.

}
          dsl.World { Hash.new }

          expect(-> {
            dsl.World { Array.new }
          }).to raise_error(Glue::MultipleWorld, /#{expected_error}/)
        end
      end

      describe 'Handling namespaced World' do
        module ModuleOne
          def method_one
            1
          end
        end

        module ModuleMinusOne
          def method_one
            -1
          end
        end

        module ModuleTwo
          def method_two
            2
          end
        end

        module ModuleThree
          def method_three
            3
          end
        end

        it 'extends the world with namespaces' do
          dsl.World(ModuleOne, module_two: ModuleTwo, module_three: ModuleThree)
          registry.begin_scenario(double('scenario').as_null_object)
          class << registry.current_world
            extend RSpec::Matchers
            expect(included_modules.inspect).to match(/ModuleOne/)
          end
          expect(registry.current_world.class).to eq Object
          expect(registry.current_world).to respond_to(:method_one)

          expect(registry.current_world.module_two.class).to eq Object
          expect(registry.current_world.module_two).to respond_to(:method_two)

          expect(registry.current_world.module_three.class).to eq Object
          expect(registry.current_world.module_three).to respond_to(:method_three)
        end

        it 'allows to inspect the included modules' do
          dsl.World(ModuleOne, module_two: ModuleTwo, module_three: ModuleThree)
          registry.begin_scenario(double('scenario').as_null_object)
          class << registry.current_world
            extend RSpec::Matchers
          end
          expect(registry.current_world.inspect).to match(/ModuleOne/)
          expect(registry.current_world.inspect).to include('ModuleTwo (as module_two)')
          expect(registry.current_world.inspect).to include('ModuleThree (as module_three)')
        end

        it 'merges methods when assigning different modules to the same namespace' do
          dsl.World(namespace: ModuleOne)
          dsl.World(namespace: ModuleTwo)
          registry.begin_scenario(double('scenario').as_null_object)
          class << registry.current_world
            extend RSpec::Matchers
          end
          expect(registry.current_world.namespace).to respond_to(:method_one)
          expect(registry.current_world.namespace).to respond_to(:method_two)
        end

        it 'resolves conflicts when assigning different modules to the same namespace' do
          dsl.World(namespace: ModuleOne)
          dsl.World(namespace: ModuleMinusOne)
          registry.begin_scenario(double('scenario').as_null_object)
          class << registry.current_world
            extend RSpec::Matchers
          end
          expect(registry.current_world.namespace).to respond_to(:method_one)
          expect(registry.current_world.namespace.method_one).to eql(-1)
        end
      end

      describe 'step argument transformations' do
        describe 'without capture groups' do
          it 'complains when registering with a with no transform block' do
            expect(-> {
              dsl.Transform('^abc$')
            }).to raise_error(Cucumber::Glue::Transform::MissingProc)
          end

          it 'complains when registering with a zero-arg transform block' do
            expect(-> {
              dsl.Transform('^abc$') {42}
            }).to raise_error(Cucumber::Glue::Transform::MissingProc)
          end

          it 'complains when registering with a splat-arg transform block' do
            expect(-> {
              dsl.Transform('^abc$') {|*splat| 42 }
            }).to raise_error(Cucumber::Glue::Transform::MissingProc)
          end

          it 'complains when transforming with an arity mismatch' do
            expect(-> {
              dsl.Transform('^abc$') {|one, two| 42 }
              registry.execute_transforms(['abc'])
            }).to raise_error(ArityMismatchError)
          end

          it 'allows registering a regexp pattern that yields the step_arg matched' do
            dsl.Transform(/^ab*c$/) {|arg| 42}

            expect(registry.execute_transforms(['ab'])).to eq ['ab']
            expect(registry.execute_transforms(['ac'])).to eq [42]
            expect(registry.execute_transforms(['abc'])).to eq [42]
            expect(registry.execute_transforms(['abbc'])).to eq [42]
          end

          it 'transforms times' do
            require 'time'
            dsl.Transform(/^(\d\d-\d\d-\d\d\d\d)$/) do |arg|
              Time.parse(arg)
            end
            expect(registry.execute_transforms(['10-0E-1971'])).to eq ['10-0E-1971']
            expect(registry.execute_transforms(['10-03-1971'])).to eq [Time.parse('10-03-1971')]
          end
        end

        describe 'with capture groups' do
          it 'complains when registering with a with no transform block' do
            expect(-> {
              dsl.Transform('^a(.)c$')
            }).to raise_error(Cucumber::Glue::Transform::MissingProc)
          end

          it 'complains when registering with a zero-arg transform block' do
            expect(-> {
              dsl.Transform('^a(.)c$') { 42 }
            }).to raise_error(Cucumber::Glue::Transform::MissingProc)
          end

          it 'complains when registering with a splat-arg transform block' do
            expect(-> {
              dsl.Transform('^a(.)c$') {|*splat| 42 }
            }).to raise_error(Cucumber::Glue::Transform::MissingProc)
          end

          it 'complains when transforming with an arity mismatch' do
            expect(-> {
              dsl.Transform('^a(.)c$') {|one, two| 42 }
              registry.execute_transforms(['abc'])
            }).to raise_error(ArityMismatchError)
          end

          it 'allows registering a regexp pattern that yields capture groups' do
            dsl.Transform(/^shape: (.+), color: (.+)$/) do |shape, color|
              {shape.to_sym => color.to_sym}
            end

            expect(registry.execute_transforms(['shape: circle, color: blue'])).to eq [{:circle => :blue}]
            expect(registry.execute_transforms(['shape: square, color: red'])).to eq [{:square => :red}]
            expect(registry.execute_transforms(['not shape: square, not color: red'])).to eq ['not shape: square, not color: red']
          end
        end

        it 'allows registering a string pattern' do
          dsl.Transform('^ab*c$') {|arg| 42}

          expect(registry.execute_transforms(['ab'])).to eq ['ab']
          expect(registry.execute_transforms(['ac'])).to eq [42]
          expect(registry.execute_transforms(['abc'])).to eq [42]
          expect(registry.execute_transforms(['abbc'])).to eq [42]
        end

        it 'gives match priority to transforms defined last' do
          dsl.Transform(/^transform_me$/) {|arg| :foo }
          dsl.Transform(/^transform_me$/) {|arg| :bar }
          dsl.Transform(/^transform_me$/) {|arg| :baz }

          expect(registry.execute_transforms(['transform_me'])).to eq [:baz]
        end

        it 'allows registering a transform which returns nil' do
          dsl.Transform('^ac$') {|arg| nil}

          expect(registry.execute_transforms(['ab'])).to eq ['ab']
          expect(registry.execute_transforms(['ac'])).to eq [nil]
        end
      end

      describe 'hooks' do
        it 'finds before hooks' do
          fish = dsl.Before('@fish'){}
          meat = dsl.Before('@meat'){}

          scenario = double('Scenario')

          expect(scenario).to receive(:accept_hook?).with(fish) { true }
          expect(scenario).to receive(:accept_hook?).with(meat) { false }
          expect(registry.hooks_for(:before, scenario)).to eq [fish]
        end

        it 'finds around hooks' do
          a = dsl.Around do |scenario, block|
          end

          b = dsl.Around('@tag') do |scenario, block|
          end

          scenario = double('Scenario')

          expect(scenario).to receive(:accept_hook?).with(a) { true }
          expect(scenario).to receive(:accept_hook?).with(b) { false }
          expect(registry.hooks_for(:around, scenario)).to eq [a]
        end
      end
    end
  end
end
