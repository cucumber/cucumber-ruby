require 'cucumber/formatter/legacy_api/adapter'
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/mappings'

module Cucumber
  module Formatter::LegacyApi
    describe Adapter do
      include Core::Gherkin::Writer
      include Core

      let(:report)    { Adapter.new(formatter, runtime.results, runtime.support_code, runtime.configuration) }
      let(:formatter) { double('formatter').as_null_object }
      let(:runtime)   { Runtime.new }
      let(:mappings)  { mappings = CustomMappings.new }

      Failure = Class.new(StandardError)

      class CustomMappings
        def test_case(test_case, mapper)
          # The adapter is built on the assumption that each test case will have at least one step. This is annoying
          # for tests, but a safe assumption for production use as we always add one hook to initialize the world.
          mapper.before {}

          # also add an after hook to make sure the adapter can cope with it
          mapper.after {}
        end

        def test_step(test_step, mapper)
          if test_step.name =~ /pass/
            mapper.map {}
          end

          if test_step.name =~ /fail/
            mapper.map { raise Failure }
          end
        end
      end

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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'a scenario with no steps' do
          execute_gherkin do
            feature do
              scenario
            end
          end

          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'a scenario with two steps, one of them failing' do
          execute_gherkin do
            feature do
              scenario do
                step 'passing'
                step 'failing'
              end
            end
          end
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'a feature with a background and an empty scenario' do
          execute_gherkin do
            feature do
              background do
                step 'passing'
              end
              scenario
            end
          end
          expect( formatter.legacy_messages ).to eq [
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
                :after_feature_element,
              :after_feature,
            :after_features,
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'a feature with a background and one scenario and one scenario outline' do
          execute_gherkin do
            feature do
              background do
                step 'passing'
              end
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'a feature with a background and one scenario outline and one scenario' do
          execute_gherkin do
            feature do
              background do
                step 'passing'
              end
              scenario_outline do
                step '<result>ing'
                examples do
                  row 'result'
                  row 'pass'
                end
              end
              scenario do
                step 'passing'
              end
            end
          end
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'a feature with a background and two scenario outlines' do
          execute_gherkin do
            feature do
              background do
                step 'passing'
              end
              scenario_outline do
                step '<result>ing'
                examples do
                  row 'result'
                  row 'pass'
                end
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'a feature with a background and one scenario outline with two rows' do
          execute_gherkin do
            feature do
              background do
                step 'passing'
              end
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'a feature with a background and one scenario outline with two examples tables' do
          execute_gherkin do
            feature do
              background do
                step 'passing'
              end
              scenario_outline do
                step '<result>ing'
                examples do
                  row 'result'
                  row 'pass'
                end
                examples do
                  row 'result'
                  row 'pass'
                end
              end
            end
          end
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'scenario outline after scenario' do
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
          ]
        end

        it 'scenario outline before scenario' do
          execute_gherkin do
            feature do
              scenario_outline do
                step '<result>ing'
                examples do
                  row 'result'
                  row 'pass'
                end
              end
              scenario do
                step 'passing'
              end
            end
          end
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
            ]
        end

        it 'scenario outline two examples tables' do
          execute_gherkin do
            feature do
              scenario_outline do
                step '<result>ing'
                examples do
                  row 'result'
                  row 'pass'
                end
                examples do
                  row 'result'
                  row 'pass'
                end
              end
            end
          end
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
            ]
        end

        it 'two scenario outline' do
          execute_gherkin do
            feature do
              scenario_outline do
                step '<result>ing'
                examples do
                  row 'result'
                  row 'pass'
                end
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
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
          expect( formatter.legacy_messages ).to eq [
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
              :after_features,
            ]
        end

        it 'a feature with a failing background and two scenarios' do
          execute_gherkin do
            feature do
              background do
                step 'failing'
              end
              scenario do
                step 'passing'
              end
              scenario do
                step 'passing'
              end
            end
          end
          expect( formatter.legacy_messages ).to eq [
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
                          :exception,
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
              :after_features,
            ]
        end

        context 'in expand mode' do
          let(:runtime) { Runtime.new expand: true }
          let(:formatter) { MessageSpy.new }

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
            expect( formatter.legacy_messages ).to eq [
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
                            :scenario_name,
                            :before_step,
                              :before_step_result,
                                :step_name,
                              :after_step_result,
                            :after_step,
                            :scenario_name,
                            :before_step,
                              :before_step_result,
                                :step_name,
                              :after_step_result,
                            :after_step,
                          :after_outline_table,
                        :after_examples,
                      :after_examples_array,
                    :after_feature_element,
                  :after_feature,
                :after_features,
              ]
          end
        end

        context 'with exception in after step hook' do

          class CustomMappingsWithAfterStepHook < CustomMappings
            def test_step(test_step, mappings)
              super
              mappings.after { raise Failure }
            end
          end

          let(:mappings) { CustomMappingsWithAfterStepHook.new }

          it 'prints the exception within the step' do
            execute_gherkin do
              feature do
                scenario do
                  step 'passing'
                end
              end
            end
            expect( formatter.legacy_messages ).to eq([
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
                :after_features,
                ])
          end
        end

        context 'with exception in before step hook' do
          it 'prints the exception within the step' do
            define_steps do
              BeforeStep do
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
                      :exception,
                      :after_step_result,
                    :after_step,
                  :after_steps,
                :after_feature_element,
              :after_feature,
            :after_features
            ])
          end
        end

        context 'with exception in a single before hook' do
          class CustomMappingsWithBeforeHook < CustomMappings
            def test_case(test_case, mappings)
              super
              mappings.before { raise Failure }
            end
          end

          let(:mappings) { CustomMappingsWithBeforeHook.new }

          it 'prints the exception after the scenario name' do
            execute_gherkin do
              feature do
                scenario do
                  step 'passing'
                end
              end
            end

            expect( formatter.legacy_messages ).to eq([
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
                :after_features,
                ])
          end

          it 'prints the exception after the background name' do
            mappings = Class.new(CustomMappings) {
              def test_case(test_case, mapper)
                mapper.before { raise Failure }
              end
            }.new

            execute_gherkin(mappings) do
              feature do
                background do
                  step 'passing'
                end
                scenario do
                  step 'passing'
                end
              end
            end

            expect( formatter.legacy_messages ).to eq([
                :before_features,
                  :before_feature,
                    :before_tags,
                    :after_tags,
                    :feature_name,
                    :before_background,
                      :background_name,
                      :exception,
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
                :after_features,
                ])
          end


          it 'prints the exception before the examples table row' do
            mappings = Class.new(CustomMappings) {
              def test_case(test_case, mapper)
                mapper.before { raise Failure }
              end
            }.new

            execute_gherkin(mappings) do
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

            expect( formatter.legacy_messages ).to eq([
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
                :after_features,
              ])
          end
        end

        context 'with exception in the first of several before hooks' do
          # This proves that the second before hook's result doesn't overwrite
          # the result of the first one.
          it 'prints the exception after the scenario name' do
            mappings = Class.new(CustomMappings) {
              def test_case(test_case, mapper)
                mapper.before { raise Failure }
                mapper.before { }
              end
            }.new

            execute_gherkin(mappings) do
              feature do
                scenario do
                  step 'passing'
                end
              end
            end

            expect( formatter.legacy_messages ).to eq([
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
                :after_features,
                ])
          end
        end

        context 'with exception in after hooks' do
          let(:mappings) do
            Class.new(CustomMappings) {
              def test_case(test_case, mapper)
                mapper.after { raise Failure }
              end
            }.new
          end

          it 'prints the exception after the steps' do

            execute_gherkin(mappings) do
              feature do
                scenario do
                  step 'passing'
                end
              end
            end

            expect( formatter.legacy_messages ).to eq([
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
              :after_features,
            ])
          end

          it 'prints the exception after the examples table row' do
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

            expect( formatter.legacy_messages ).to eq([
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
              :after_features,
            ])
          end
        end

        context 'with exception in the first of several after hooks' do
          let(:mappings) do
            Class.new(CustomMappings) {
              def test_case(test_case, mapper)
                mapper.after { raise Failure }
                mapper.after { }
              end
            }.new
          end

          it 'prints the exception after the steps' do
            execute_gherkin do
              feature do
                scenario do
                  step 'passing'
                end
              end
            end

            expect( formatter.legacy_messages ).to eq([
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
              :after_features,
            ])
          end
        end

        context 'with an exception in an after hook but no steps' do
          let(:mappings) do
            Class.new(CustomMappings) {
              def test_case(test_case, mapper)
                mapper.after { raise Failure }
              end
            }.new
          end

          it 'prints the exception after the steps' do
            execute_gherkin do
              feature do
                scenario do
                end
              end
            end

            expect( formatter.legacy_messages ).to eq([
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
                  :after_feature_element,
                :after_feature,
              :after_features,
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

        def legacy_messages
          @messages - [
            :before_test_step,
            :before_test_case,
            :after_test_step,
            :after_test_case,
            :done
          ]
        end

        def method_missing(message, *args)
          @messages << message
        end

        def respond_to_missing?(name, include_private = false)
          true
        end
      end

      def execute_gherkin(custom_mappings = mappings, &gherkin)
        execute [gherkin(&gherkin)], custom_mappings, report
      end

    end
  end
end
