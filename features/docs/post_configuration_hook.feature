Feature: Post Configuration Hook [#423]

  In order to extend Cucumber
  As a developer
  I want to manipulate the Cucumber configuration after it has been created

  Scenario: Changing the output format
    Given a file named "features/support/env.rb" with:
      """
      AfterConfiguration do |config|
        config.formats << ['json', {}, config.out_stream]
      end
      """
    And a file named "features/simple_scenario.feature" with:
      """
      Feature:
        Scenario:
          Given a step
      """
    When I run `cucumber features`
    Then the stderr should not contain anything
    And the output should contain:
      """
      "uri": "features/simple_scenario.feature"
      """

  Scenario: feature directories read from configuration
    Given a file named "features/support/env.rb" with:
      """
      AfterConfiguration do |config|
        config.out_stream << "AfterConfiguration hook read feature directories: #{config.feature_dirs.join(', ')}"
      end
      """
    When I run `cucumber features`
    Then the stderr should not contain anything
    And the output should contain:
      """
      AfterConfiguration hook read feature directories: features
      """
