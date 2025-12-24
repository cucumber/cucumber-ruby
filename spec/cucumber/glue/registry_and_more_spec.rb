# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/glue/registry_and_more'
require 'cucumber/cucumber_expressions/parameter_type'
require 'support/fake_objects'

module Cucumber
  module Glue
    describe StepDefinition do
      let(:user_interface) { double('user interface') }
      let(:registry)       { support_code.registry }
      let(:support_code) { Cucumber::Runtime::SupportCode.new(user_interface) }
      let(:dsl) do
        registry
        Object.new.extend(Glue::Dsl)
      end

      describe '#load_code_file' do
        after(:each) do
          FileUtils.rm_rf('tmp1.rb')
          FileUtils.rm_rf('tmp2.rb')
          FileUtils.rm_rf('tmp3.rb')
          FileUtils.rm_rf('docs1.md')
          FileUtils.rm_rf('docs2.md')
          FileUtils.rm_rf('docs3.md')
        end

        let(:value1) do
          <<~STRING
            class Foo
              def self.value; 1; end
            end
          STRING
        end
        let(:value2) do
          <<~STRING
            class Foo
              def self.value; 2; end
            end
          STRING
        end

        let(:value3) do
          <<~STRING
            class Foo
              def self.value; 3; end
            end
          STRING
        end

        def a_file_called(name)
          File.open(name, 'w') do |f|
            f.puts yield
          end
        end

        context 'when not specifying the loading strategy' do
          it 'does not re-load the file when called multiple times' do
            a_file_called('tmp1.rb') { value1 }
            registry.load_code_file('tmp1.rb')
            a_file_called('tmp1.rb') { value2 }
            registry.load_code_file('tmp1.rb')

            expect(Foo.value).to eq(1)
          end

          it 'only loads ruby files' do
            a_file_called('tmp1.rb') { value1 }
            a_file_called('docs1.md') { value3 }
            registry.load_code_file('tmp1.rb')
            registry.load_code_file('docs1.md')

            expect(Foo.value).not_to eq(3)
          end
        end

        context 'when using `use_legacy_autoloader`' do
          before(:each) { allow(Cucumber).to receive(:use_legacy_autoloader).and_return(true) }

          it 're-loads the file when called multiple times' do
            a_file_called('tmp2.rb') { value1 }
            registry.load_code_file('tmp2.rb')
            a_file_called('tmp2.rb') { value2 }
            registry.load_code_file('tmp2.rb')

            expect(Foo.value).to eq(2)
          end

          it 'only loads ruby files' do
            a_file_called('tmp2.rb') { value1 }
            a_file_called('docs2.md') { value3 }
            registry.load_code_file('tmp2.rb')
            registry.load_code_file('docs2.md')

            expect(Foo.value).not_to eq(3)
          end
        end

        context 'when explicitly NOT using `use_legacy_autoloader`' do
          before(:each) { allow(Cucumber).to receive(:use_legacy_autoloader).and_return(false) }
          after(:each) { FileUtils.rm_rf('tmp3.rb') }

          it 'does not re-load the file when called multiple times' do
            a_file_called('tmp3.rb') { value1 }
            registry.load_code_file('tmp3.rb')
            a_file_called('tmp3.rb') { value2 }
            registry.load_code_file('tmp3.rb')

            expect(Foo.value).to eq(1)
          end

          it 'only loads ruby files' do
            a_file_called('tmp3.rb') { value1 }
            a_file_called('docs3.md') { value3 }
            registry.load_code_file('tmp3.rb')
            registry.load_code_file('docs3.md')

            expect(Foo.value).not_to eq(3)
          end
        end
      end

      describe 'Handling the World' do
        it 'raises an error if the world is nil' do
          dsl.World {}

          expect { registry.begin_scenario(nil) }.to raise_error(Glue::NilWorld).with_message('World procs should never return nil')
        end

        it 'implicitly extends the world with modules' do
          dsl.World(FakeObjects::ModuleOne, FakeObjects::ModuleTwo)
          registry.begin_scenario(double('scenario').as_null_object)
          class << registry.current_world
            extend RSpec::Matchers

            expect(included_modules).to include(FakeObjects::ModuleOne).and include(FakeObjects::ModuleTwo)
          end
        end

        it 'places the current world inside the `Object` superclass' do
          dsl.World(FakeObjects::ModuleOne, FakeObjects::ModuleTwo)
          registry.begin_scenario(double('scenario').as_null_object)

          expect(registry.current_world.class).to eq(Object)
        end

        it 'raises error when we try to register more than one World proc' do
          dsl.World { {} }

          expect { dsl.World { [] } }.to raise_error(Glue::MultipleWorld, /^You can only pass a proc to #World once/)
        end
      end

      describe 'Handling namespaced World' do
        it 'can still handle top level methods inside the world the world with namespaces' do
          dsl.World(FakeObjects::ModuleOne, module_two: FakeObjects::ModuleTwo, module_three: FakeObjects::ModuleThree)
          registry.begin_scenario(double('scenario').as_null_object)

          expect(registry.current_world).to respond_to(:method_one)
        end

        it 'can scope calls to a specific namespaced module' do
          dsl.World(FakeObjects::ModuleOne, module_two: FakeObjects::ModuleTwo, module_three: FakeObjects::ModuleThree)
          registry.begin_scenario(double('scenario').as_null_object)

          expect(registry.current_world.module_two).to respond_to(:method_two)
        end

        it 'can scope calls to a different specific namespaced module' do
          dsl.World(FakeObjects::ModuleOne, module_two: FakeObjects::ModuleTwo, module_three: FakeObjects::ModuleThree)
          registry.begin_scenario(double('scenario').as_null_object)

          expect(registry.current_world.module_three).to respond_to(:method_three)
        end

        it 'can show all the namespaced included modules' do
          dsl.World(FakeObjects::ModuleOne, module_two: FakeObjects::ModuleTwo, module_three: FakeObjects::ModuleThree)
          registry.begin_scenario(double('scenario').as_null_object)

          expect(registry.current_world.inspect).to include('ModuleTwo (as module_two)').and include('ModuleThree (as module_three)')
        end

        it 'merges methods when assigning different modules to the same namespace' do
          dsl.World(namespace: FakeObjects::ModuleOne)
          dsl.World(namespace: FakeObjects::ModuleTwo)
          registry.begin_scenario(double('scenario').as_null_object)

          expect(registry.current_world.namespace).to respond_to(:method_one).and respond_to(:method_two)
        end

        it 'resolves conflicts by using the latest defined definition when assigning different modules to the same namespace' do
          dsl.World(namespace: FakeObjects::ModuleOne)
          dsl.World(namespace: FakeObjects::ModuleTwo)
          registry.begin_scenario(double('scenario').as_null_object)

          expect(registry.current_world.namespace.method_one).to eq(2)
        end
      end

      describe 'hooks' do
        it 'finds before hooks' do
          fish = dsl.Before('@fish') {}
          meat = dsl.Before('@meat') {}

          scenario = double('Scenario')

          allow(scenario).to receive(:accept_hook?).with(fish).and_return(true)
          allow(scenario).to receive(:accept_hook?).with(meat).and_return(false)
          expect(registry.hooks_for(:before, scenario)).to eq([fish])
        end

        it 'finds around hooks' do
          a = dsl.Around {}
          b = dsl.Around('@tag') {}

          scenario = double('Scenario')

          allow(scenario).to receive(:accept_hook?).with(a).and_return(true)
          allow(scenario).to receive(:accept_hook?).with(b).and_return(false)
          expect(registry.hooks_for(:around, scenario)).to eq([a])
        end
      end
    end

    describe RegistryAndMore do
      let(:registry) { described_class.new(double, configuration) }
      let(:configuration) { Configuration.new({}) }

      describe '#parameter_type_envelope' do
        subject(:envelope) { registry.send(:parameter_type_envelope, parameter_type) }

        let(:parameter_type) { CucumberExpressions::ParameterType.new(name, regexp, type, transformer, use_for_snippets, prefer_for_regexp_match) }
        let(:id) { '279e0f28-c91b-4de2-89c0-e7fbc2a15406' }
        let(:name) { 'person' }
        let(:regexp) { /"[^"]+"/ }
        let(:type) { String }
        let(:transformer) { ->(s) { s } }
        let(:use_for_snippets) { false }
        let(:prefer_for_regexp_match) { true }

        before do
          allow(configuration).to receive_message_chain(:id_generator, :new_id).and_return(id) # rubocop:disable RSpec/MessageChain
        end

        it 'produces an envelope with the expected contents' do
          expect(envelope).to be_a Cucumber::Messages::Envelope
          expect(envelope.parameter_type).to be_a Cucumber::Messages::ParameterType
          expect(envelope.parameter_type).to have_attributes(
            id: '279e0f28-c91b-4de2-89c0-e7fbc2a15406',
            name: 'person',
            regular_expressions: [%("[^"]+")],
            prefer_for_regular_expression_match: true,
            use_for_snippets: false,
            source_reference: anything # tested in later cases
          )
        end

        context 'when provided a ParameterType with transformer being a lambda' do
          let(:transformer) { ->(s) { s } }

          it 'includes the lambda source-location in the envelope' do
            expect(envelope.parameter_type.source_reference).to be_a Cucumber::Messages::SourceReference
            expect(envelope.parameter_type.source_reference).to have_attributes(
              uri: transformer.source_location[0],
              location: have_attributes(line: transformer.source_location[1])
            )
          end
        end

        context 'when provided a ParameterType with transformer being a bound method, which has no source location' do
          let(:transformer) { String.method(:new) }

          it 'does not include the source-location in the envelope' do
            expect(envelope.parameter_type.source_reference).to be_nil
          end
        end
      end
    end
  end
end
