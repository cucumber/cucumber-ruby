Feature: Named hooks

  In order to spot errors easily in hooks
  As a developer
  I can give names to hooks

  Scenario: Hooks can be named
    Given a file named "features/support/env.rb" with:
      """
      Before(name: 'Named before hook') do
        # no-op
      end
      """
    And a file named "features/simple_scenario.feature" with:
      """
      Feature:
        Scenario:
          Given a step
      """
    When I run `cucumber features --publish-quiet --format message`
    Then the stderr should not contain anything
    And the output should contain NDJSON with key "name" and value "Named before hook"

  Scenario: All kind of hooks can be named
    Given a file named "features/support/env.rb" with:
      """
      Before(name: 'Named before hook') {}
      After(name: 'Named after hook') {}
      BeforeAll(name: 'Named before_all hook') {}
      AfterAll(name: 'Named after_all hook') {}
      AfterStep(name: 'Named after_step hook') {}
      Around(name: 'Named around hook') {}
      InstallPlugin(name: 'Named install_plugin hook') {}
      """
    And a file named "features/simple_scenario.feature" with:
      """
      Feature:
        Scenario:
          Given a step
      """
    When I run `cucumber features --publish-quiet --format message`
    Then the stderr should not contain anything
    And the output should contain NDJSON with key "name" and value "Named before hook"
    And the output should contain NDJSON with key "name" and value "Named after hook"
    And the output should contain NDJSON with key "name" and value "Named before_all hook"
    And the output should contain NDJSON with key "name" and value "Named after_all hook"
    And the output should contain NDJSON with key "name" and value "Named after_step hook"
    And the output should contain NDJSON with key "name" and value "Named around hook"
    And the output should contain NDJSON with key "name" and value "Named install_plugin hook"
