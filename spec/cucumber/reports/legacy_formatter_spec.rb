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

    context 'message order' do
      let(:formatter) { MessageSpy.new }

      it 'two features' do
        gherkin_docs = [
          gherkin do
            feature do
              scenario do
                step 'passing'
              end
            end
          end,
          gherkin do
            feature do
              scenario do
                step 'passing'
              end
            end
          end,
        ]
        execute gherkin_docs, mappings, report
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
              :after_feature_element,
            :after_feature,
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
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      it 'a scenario with no steps' do
        execute_gherkin do
          feature do
            scenario
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
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      it 'a scenario with no steps coming after another scenario' do
        execute_gherkin do
          feature do
            scenario do
              step 'passing'
            end
            scenario
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
              :after_feature_element,
              :before_feature_element,
                :before_tags,
                  :after_tags,
                :scenario_name,
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      it 'a scenario with one step' do
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
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      it 'a scenario with two steps, on of them failing' do
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

      it 'a feature with two scenarios' do
        execute_gherkin do
          feature do
            scenario do
              step 'passing'
            end
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
              :after_feature_element,
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
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      it 'a feature with a background and two scenarios' do
        execute_gherkin do
          feature do
            background do
              step 'passing'
            end
            scenario do
              step 'passing'
            end
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
              :before_background,
                :background_name,
                :before_steps,
                  :before_step,
                    :before_step_result,
                      :step_name,
                    :after_step_result,
                  :after_step,
                :after_steps,
              :after_background,
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
              :after_feature_element,
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
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      it 'a feature with a background with two steps' do
        execute_gherkin do
          feature do
            background do
              step 'passing'
              step 'passing'
            end
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
              :before_background,
                :background_name,
                :before_steps,
                  :before_step,
                    :before_step_result,
                      :step_name,
                    :after_step_result,
                  :after_step,
                  :before_step,
                    :before_step_result,
                      :step_name,
                    :after_step_result,
                  :after_step,
                :after_steps,
              :after_background,
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
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      it 'a feature with a background' do
        execute_gherkin do
          feature do
            background do
              step 'passing'
            end
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
          :before_background,
          :background_name,
          :before_steps,
          :before_step,
          :before_step_result,
          :step_name,
          :after_step_result,
          :after_step,
          :after_steps,
          :after_background,
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
          :after_feature_element,
          :after_feature,
          :after_features
        ]
      end

      it 'scenario outline' do
        execute_gherkin do
          feature do
            scenario_outline do
              step '<result>ing'
              examples do
                row 'result'
                row 'pass'
              end
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
                :before_examples_array,
                  :before_examples,
                    :examples_name,
                    :before_outline_table,
                      :before_table_row,
                        :before_table_cell,
                          :table_cell_value,
                        :after_table_cell,
                      :after_table_row,
                      :before_table_row,
                        :before_table_cell,
                          :table_cell_value,
                        :after_table_cell,
                      :after_table_row,
                    :after_outline_table,
                  :after_examples,
                :after_examples_array,
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      it 'scenario outline with scenario' do
        execute_gherkin do
          feature do
            scenario do
              step 'passing'
            end
            scenario_outline do
              step '<result>ing'
              examples do
                row 'result'
                row 'pass'
              end
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
              :after_feature_element,
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
                :before_examples_array,
                  :before_examples,
                    :examples_name,
                    :before_outline_table,
                      :before_table_row,
                        :before_table_cell,
                          :table_cell_value,
                        :after_table_cell,
                      :after_table_row,
                      :before_table_row,
                        :before_table_cell,
                          :table_cell_value,
                        :after_table_cell,
                      :after_table_row,
                    :after_outline_table,
                  :after_examples,
                :after_examples_array,
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end
      it 'scenario outline two rows' do
        execute_gherkin do
          feature do
            scenario_outline do
              step '<result>ing'
              examples do
                row 'result'
                row 'pass'
                row 'pass'
              end
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
                :before_examples_array,
                  :before_examples,
                    :examples_name,
                    :before_outline_table,
                      :before_table_row,
                        :before_table_cell,
                          :table_cell_value,
                        :after_table_cell,
                      :after_table_row,
                      :before_table_row,
                        :before_table_cell,
                          :table_cell_value,
                        :after_table_cell,
                      :after_table_row,
                      :before_table_row,
                        :before_table_cell,
                          :table_cell_value,
                        :after_table_cell,
                      :after_table_row,
                    :after_outline_table,
                  :after_examples,
                :after_examples_array,
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      it 'failing scenario outline' do
        execute_gherkin do
          feature do
            scenario_outline do
              step '<result>ing'
              examples do
                row 'result'
                row 'fail'
              end
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
                :before_examples_array,
                  :before_examples,
                    :examples_name,
                    :before_outline_table,
                      :before_table_row,
                        :before_table_cell,
                          :table_cell_value,
                        :after_table_cell,
                      :after_table_row,
                      :before_table_row,
                        :before_table_cell,
                          :table_cell_value,
                        :after_table_cell,
                      :after_table_row,
                    :after_outline_table,
                  :after_examples,
                :after_examples_array,
              :after_feature_element,
            :after_feature,
          :after_features
        ]
      end

      context 'with exception in after step hook' do
        it 'prints the exception within the step' do
          define_steps do
            AfterStep do
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
          expect( formatter.messages ).to eq([
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
                  :exception,
                :after_steps,
              :after_feature_element,
            :after_feature,
          :after_features
          ])
        end
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

          expect( formatter.messages ).to eq([
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
          ])
        end

        it 'prints the exception before the examples table row' do
          define_steps do
            Before do
              raise 'an exception'
            end
          end
          execute_gherkin do
            feature do
              scenario_outline do
                step '<status>ing'
                examples do
                  row 'status'
                  row 'pass'
                end
              end
            end
          end

          expect( formatter.messages ).to eq([
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
                  :before_examples_array,
                    :before_examples,
                      :examples_name,
                      :before_outline_table,
                        :before_table_row,
                          :before_table_cell,
                            :table_cell_value,
                          :after_table_cell,
                        :after_table_row,
                        :exception,
                        :before_table_row,
                          :before_table_cell,
                            :table_cell_value,
                          :after_table_cell,
                        :after_table_row,
                      :after_outline_table,
                    :after_examples,
                  :after_examples_array,
                :after_feature_element,
              :after_feature,
            :after_features
          ])
        end
      end

      context 'with exception in after hooks' do
        it 'prints the exception after the steps' do
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

          expect( formatter.messages ).to eq([
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
          ])
        end

        it 'prints the exception after the examples table row' do
          define_steps do
            After do
              raise 'an exception'
            end
          end
          execute_gherkin do
            feature do
              scenario_outline do
                step '<status>ing'
                examples do
                  row 'status'
                  row 'pass'
                end
              end
            end
          end

          expect( formatter.messages ).to eq([
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
                  :before_examples_array,
                    :before_examples,
                      :examples_name,
                      :before_outline_table,
                        :before_table_row,
                          :before_table_cell,
                            :table_cell_value,
                          :after_table_cell,
                        :after_table_row,
                        :before_table_row,
                          :before_table_cell,
                            :table_cell_value,
                          :after_table_cell,
                        :after_table_row,
                        :exception,
                      :after_outline_table,
                    :after_examples,
                  :after_examples_array,
                :after_feature_element,
              :after_feature,
            :after_features
          ])
        end
      end
    end

    it 'passes an object responding to failed? with the after_feature_element message' do
      expect( formatter ).to receive(:after_feature_element) do |scenario|
        expect( scenario ).to be_failed
      end
      execute_gherkin do
        feature do
          scenario do
            step 'failing'
          end
        end
      end
    end

    context 'in strict mode' do
      let(:runtime) { Runtime.new strict: true }

      it 'passes an exception to the formatter for undefined steps' do
      expect( formatter ).to receive(:exception) do |exception|
        expect( exception.message ).to eq %{Undefined step: "this step is undefined"}
      end
        execute_gherkin do
          feature do
            scenario do
              step 'this step is undefined'
            end
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
