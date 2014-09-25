Feature: Hook output feature

  Calls to puts and embed in hook, should be passed to the formatters.

  Background:
    Given the standard step definitions

  Scenario: Output from hooks
    Given a file named "features/test.feature" with:
      """
      Feature:
        Scenario:
          Given this step passes
        Scenario Outline:
          Given this step <status>
          Examples:
          | status |
          | passes  |
      """
    And a file named "features/step_definitions/output_steps.rb" with:
      """
      Before do
        puts "Before hook 1"
        embed "src", "mime_type", "label"
      end

      Before do
        puts "Before hook 2"
        embed "src", "mime_type", "label"
      end
 
      AfterStep do
        puts "AfterStep hook 1"
        embed "src", "mime_type", "label"
      end

      AfterStep do
        puts "AfterStep hook 2"
        embed "src", "mime_type", "label"
      end

      After do
        puts "After hook 1"
        embed "src", "mime_type", "label"
      end

      After do
        puts "After hook 2"
        embed "src", "mime_type", "label"
      end
      """
    When I run `cucumber -f debug`
    Then the stderr should not contain anything
    Then it should pass with:
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
            puts
            embed
            puts
            embed
            before_steps
              before_step
                before_step_result
                  step_name
                after_step_result
              after_step
              puts
              embed
              puts
              embed
            after_steps
            puts
            embed
            puts
            embed
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
            after_steps
            before_examples_array
              before_examples
                examples_name
                before_outline_table
                  before_table_row
                    before_table_cell
                      table_cell_value
                    after_table_cell
                  after_table_row
                  puts
                  embed
                  puts
                  embed
                  before_table_row
                    before_table_cell
                      table_cell_value
                    after_table_cell
                    puts
                    embed
                    puts
                    embed
                    puts
                    embed
                    puts
                    embed
                  after_table_row
                after_outline_table
              after_examples
            after_examples_array
          after_feature_element
        after_feature
      after_features
      """
