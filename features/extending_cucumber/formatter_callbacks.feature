Feature: Formatter Callback

  Scenario: callback if not expanded
    Given a file named "features/f.feature" with:
      """
      Feature: I'll use my own
        because I'm worth it
        Scenario: just print me
          Given this step works
        Scenario Outline: outline
          Given <x> step works
          Then <y>
          Examples:
          |x|y|
          |this|that|
          |here|there|
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^.+ step works$/ do
      end
      Then /^that|there$/ do
      end
      """
    When I run `cucumber features/f.feature --format debug`
    Then it should pass with exactly:
      """
      before_features
        before_feature
          before_tags
          after_tags
          feature_name
          before_feature_element
            before_tags
            after_tags
            scenario_name
            before_steps
              before_step
                before_step_result
                  step_name
                after_step_result
              after_step
            after_steps
          after_feature_element
          before_feature_element
            before_tags
            after_tags
            scenario_name
            before_steps
              before_step
                before_step_result
                  step_name
                after_step_result
              after_step
              before_step
                before_step_result
                  step_name
                after_step_result
              after_step
            after_steps
            before_examples_array
              before_examples
                examples_name
                before_outline_table
                  before_table_row
                    before_table_cell
                      table_cell_value
                    after_table_cell
                    before_table_cell
                      table_cell_value
                    after_table_cell
                  after_table_row
                  before_table_row
                    before_table_cell
                      table_cell_value
                    after_table_cell
                    before_table_cell
                      table_cell_value
                    after_table_cell
                  after_table_row
                  before_table_row
                    before_table_cell
                      table_cell_value
                    after_table_cell
                    before_table_cell
                      table_cell_value
                    after_table_cell
                  after_table_row
                after_outline_table
              after_examples
            after_examples_array
          after_feature_element
        after_feature
      after_features

      """

  Scenario: callback if expanded
    Given a file named "features/f.feature" with:
      """
      Feature: I'll use my own
        because I'm worth it
        Scenario: just print me
          Given this step works
        Scenario Outline: outline
          Given <x> step works
          Then <y>
          Examples:
          |x|y|
          |this|that|
          |here|there|
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^.+ step works$/ do
      end
      Then /^that|there$/ do
      end
      """
    When I run `cucumber features/f.feature --format debug --expand`
    Then it should pass with exactly:
      """
      before_features
        before_feature
          before_tags
          after_tags
          feature_name
          before_feature_element
            before_tags
            after_tags
            scenario_name
            before_steps
              before_step
                before_step_result
                  step_name
                after_step_result
              after_step
            after_steps
          after_feature_element
          before_feature_element
            before_tags
            after_tags
            scenario_name
            before_steps
              before_step
                before_step_result
                  step_name
                after_step_result
              after_step
              before_step
                before_step_result
                  step_name
                after_step_result
              after_step
            after_steps
            before_examples_array
              before_examples
                examples_name
                before_outline_table
                  scenario_name
                  before_step
                    before_step_result
                      step_name
                    after_step_result
                  after_step
                  before_step
                    before_step_result
                      step_name
                    after_step_result
                  after_step
                  scenario_name
                  before_step
                    before_step_result
                      step_name
                    after_step_result
                  after_step
                  before_step
                    before_step_result
                      step_name
                    after_step_result
                  after_step
                after_outline_table
              after_examples
            after_examples_array
          after_feature_element
        after_feature
      after_features

      """
