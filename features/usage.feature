Feature: Cucumber command line
  In order to be able to write an editor plugin that can jump between
  steps and step definitions, Cucumber must provide a way to
  display how they are related.

  Scenario: List usage of step definitions
    When I run cucumber features --format usage --dry-run
    Then it should pass with
      """
      /^passing without a table$/          # features/step_definitions/sample_steps.rb:12
       Given passing without a table       # features/background/failing_background_after_success.feature:4
       Given <state> without a table       # features/outline_sample.feature:6
       Given <other_state> without a table # features/outline_sample.feature:7
      /^failing without a table$/    # features/step_definitions/sample_steps.rb:15
       Given failing without a table # features/background/failing_background.feature:4
       Given failing without a table # features/background/scenario_outline_failing_background.feature:4
      /^a step definition that calls an undefined step$/    # features/step_definitions/sample_steps.rb:19
       Given a step definition that calls an undefined step # features/call_undefined_step_from_step_def.feature:4
      /^call step "(.*)"$/                                              # features/step_definitions/sample_steps.rb:23
       Given call step "a step definition that calls an undefined step" # features/call_undefined_step_from_step_def.feature:7
      /^'(.+)' cukes$/   # features/step_definitions/sample_steps.rb:27
       And '10' cukes    # features/background/failing_background.feature:5
       Given '10' cukes  # features/background/passing_background.feature:4
       Given '10' cukes  # features/background/scenario_outline_passing_background.feature:4
      /^I should have '(.+)' cukes$/      # features/step_definitions/sample_steps.rb:31
       Then I should have '10' cukes      # features/background/failing_background.feature:8
       Then I should have '10' cukes      # features/background/failing_background.feature:11
       Then I should have '10' cukes      # features/background/passing_background.feature:7
       Then I should have '10' cukes      # features/background/passing_background.feature:10
       Then I should have '10' cukes      # features/background/pending_background.feature:7
       Then I should have '10' cukes      # features/background/pending_background.feature:10
       Then I should have '<count>' cukes # features/background/scenario_outline_failing_background.feature:7
       Then I should have '<count>' cukes # features/background/scenario_outline_failing_background.feature:13
       Then I should have '<count>' cukes # features/background/scenario_outline_passing_background.feature:7
       Then I should have '<count>' cukes # features/background/scenario_outline_passing_background.feature:13
      /^'(.+)' global cukes$/   # features/step_definitions/sample_steps.rb:35
       And '10' global cukes    # features/background/failing_background_after_success.feature:5
      /^I should have '(.+)' global cukes$/   # features/step_definitions/sample_steps.rb:42
       Then I should have '10' global cukes   # features/background/failing_background_after_success.feature:8
       Then I should have '10' global cukes   # features/background/failing_background_after_success.feature:11
      /^table$/    # features/step_definitions/sample_steps.rb:46
       Given table # features/background/multiline_args_background.feature:4
      /^multiline string$/   # features/step_definitions/sample_steps.rb:50
       And multiline string  # features/background/multiline_args_background.feature:7
      /^the table should be$/   # features/step_definitions/sample_steps.rb:54
       Then the table should be # features/background/multiline_args_background.feature:14
       Then the table should be # features/background/multiline_args_background.feature:24
      /^the multiline string should be$/   # features/step_definitions/sample_steps.rb:58
       Then the multiline string should be # features/background/multiline_args_background.feature:17
       Then the multiline string should be # features/background/multiline_args_background.feature:27
      /^passing$/    # features/step_definitions/sample_steps.rb:5
       Given passing # features/sample.feature:10
      /^failing expectation$/    # features/step_definitions/sample_steps.rb:62
       Given failing expectation # features/failing_expectation.feature:4
      /^failing$/    # features/step_definitions/sample_steps.rb:8
       Given failing # features/sample.feature:16

      """

