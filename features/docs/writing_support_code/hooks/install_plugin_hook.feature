Feature: InstallPlugin Hook

  In order to extend Cucumber
  As a developer
  I want to manipulate the Cucumber configuration after it has been created

  Scenario: Changing the output format
    Given a file named "features/support/env.rb" with:
      """
      InstallPlugin do |config|
        config.formats << ['message', {}, config.out_stream]
      end
      """
    And a file named "features/simple_scenario.feature" with:
      """
      Feature:
        Scenario:
          Given a step
      """
    When I run `cucumber features --publish-quiet`
    Then the stderr should not contain anything
    And the output should contain NDJSON with key "uri" and value "features/simple_scenario.feature"

  Scenario: feature directories read from configuration
    Given a file named "features/support/env.rb" with:
      """
      InstallPlugin do |config|
        config.out_stream << "InstallPlugin hook read feature directories: #{config.feature_dirs.join(', ')}"
      end
      """
    When I run `cucumber features --publish-quiet`
    Then the stderr should not contain anything
    And the output should contain:
      """
      InstallPlugin hook read feature directories: features
      """
