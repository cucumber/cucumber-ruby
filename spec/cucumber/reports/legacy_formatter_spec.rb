require 'cucumber/reports/legacy_formatter'
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/mappings'

module Cucumber
  describe Reports::LegacyFormatter do
    include Core::Gherkin::Writer
    include Core

    let(:report)    { Reports::LegacyFormatter.new(runtime, [formatter]) }
    let(:formatter) { double('formatter').as_null_object }
    let(:runtime)   { Runtime.new }
    let(:mappings)  { Mappings.new(runtime) }

    before(:each) do
      define_steps do
        Given(/pass/) { }
        Given(/fail/) { raise Failure }
      end
    end
    Failure = Class.new(StandardError)

    describe 'message order' do
      let(:formatter) { MessageSpy.new }

      it 'calls events in the expected order' do
        execute_gherkin do
          feature do
            scenario do
              step 'passing'
              step 'failing'
            end
          end
        end
        expect( formatter.messages ).to eq [
          :before_features,
          :before_feature,
          :before_tags,
          :after_tags,
          :feature_name,
          :before_feature_element,
          :before_tags,
          :after_tags,
          :scenario_name,
          :before_steps,
          :before_step,
          :before_step_result,
          :step_name,
          :after_step_result,
          :after_step,
          :before_step,
          :before_step_result,
          :step_name,
          :exception,
          :after_step_result,
          :after_step,
          :after_steps,
          :after_feature_element,
          :after_feature,
          :after_features
        ]
      end

      context 'with exception in before hooks' do
        it 'prints the exception after the scenario name' do
          define_steps do
            Before do
              raise 'an exception'
            end
          end
          execute_gherkin do
            feature do
              scenario do
                step 'passing'
              end
            end
          end

          expect( formatter.messages ).to eq [
            :before_features,
            :before_feature,
            :before_tags,
            :after_tags,
            :feature_name,
            :before_feature_element,
            :before_tags,
            :after_tags,
            :scenario_name,
            :exception,
            :before_steps,
            :before_step,
            :before_step_result,
            :step_name,
            :after_step_result,
            :after_step,
            :after_steps,
            :after_feature_element,
            :after_feature,
            :after_features
          ]
        end

      end

      context 'with exception in after hooks' do
        it 'prints the exception after the scenario name' do
          define_steps do
            After do
              raise 'an exception'
            end
          end
          execute_gherkin do
            feature do
              scenario do
                step 'passing'
              end
            end
          end

          expect( formatter.messages ).to eq [
            :before_features,
            :before_feature,
            :before_tags,
            :after_tags,
            :feature_name,
            :before_feature_element,
            :before_tags,
            :after_tags,
            :scenario_name,
            :before_steps,
            :before_step,
            :before_step_result,
            :step_name,
            :after_step_result,
            :after_step,
            :after_steps,
            :exception,
            :after_feature_element,
            :after_feature,
            :after_features
          ]
        end

      end

    end

    describe 'API translation' do

      context 'with one failing feature that has one failing scenario' do

        after do
          execute_gherkin do
            feature do
              scenario do
                step 'failing'
              end
            end
          end
        end

        it 'passes an object responding to failed? with the after_feature_element message' do
          expect( formatter ).to receive(:after_feature_element) do |scenario|
            expect( scenario ).to be_failed
          end
        end

        it 'passes an nil with the before_features message' do
          expect( formatter ).to receive(:before_features).with(nil)
        end

        describe 'after_step_result message arguments' do
          def after_step_result_argument(arg_name)
            arg_position = {
              :keyword           => 0,
              :step_match        => 1,
              :multiline_arg     => 2,
              :invocation_result => 3,
              :exception         => 4,
              :indentation_level => 5,
              :background        => 6,
              :location          => 7
            }.fetch(arg_name) {
              raise "Unknown argument for name #{arg_name.inspect}"
            }
            expect( formatter ).to receive(:after_step_result) do |*args|
              argument = args.fetch(arg_position)
              yield(argument)
            end
          end

          specify 'the keyword is "Given "' do
            after_step_result_argument(:keyword) do |keyword|
              expect( keyword ).to eq 'Given '
            end
          end

          specify 'the step match matches the step definition' do
            after_step_result_argument(:step_match) do |step_match|
              expect( step_match.name_to_match ).to eq 'failing'
            end
          end

          specify 'the multiline_arg is empty' do
            after_step_result_argument(:multiline_arg) do |multiline_arg|
              #TODO: add #empty? to multiline_args objects in core
              expect( multiline_arg.to_sexp ).to be_empty
            end
          end

          specify 'the 4th argument is the result of the step invocation' do
            after_step_result_argument(:invocation_result) do |invocation_result|
              expect( invocation_result ).to eq :failed
            end
          end

          specify 'the exception is the error raised in the step' do
            after_step_result_argument(:exception) do |exception|
              expect( exception ).to be_a Failure
            end
          end

          specify 'the indentation level is 1' do
            after_step_result_argument(:indentation_level) do |indentation_level|
              expect( indentation_level ).to eq 1
            end
          end

          specify 'there is no background' do
            after_step_result_argument(:background) do |background|
              expect( background ).to be_nil
            end
          end

          specify 'the location matches a file colon line pattern' do
            after_step_result_argument(:location) do |location|
              file_colon_line_matcher = /^[\.\/\w]+\:\d+$/
              expect( location ).to match(file_colon_line_matcher)
            end
          end
        end

        it 'passes an object that has the test suite duration to the after_feature message' do
          expect( formatter ).to receive(:after_features) do |features|
            expect( features ).to respond_to :duration
          end
        end
      end
    end

    class MessageSpy
      attr_reader :messages

      def initialize
        @messages = []
      end

      def method_missing(message, *args)
        @messages << message
      end

      def respond_to_missing?(name, include_private = false)
        true
      end
    end

    def execute_gherkin(&gherkin)
      execute [gherkin(&gherkin)], mappings, report
    end

    def define_steps(&block)
      runtime.load_programming_language('rb')
      dsl = Object.new
      dsl.extend RbSupport::RbDsl
      dsl.instance_exec &block
    end

  end
end
