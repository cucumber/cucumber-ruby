@wip @spawn
Feature: List step defs as json

  In order to build tools on top of Cucumber
  As a tool developer
  I want to be able to query a features directory for all the step definitions it contains

  Background:
    Given a directory named "features"

  Scenario: Two Ruby step definitions, in the same file
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given(/foo/i)  { }
      Given(/b.r/xm) { }
      """
    And a file named "list_step_definitions.rb" with:
      """
      require 'cucumber'
      puts Cucumber::StepDefinitions.new.to_json

      """
    When I run `bundle exec ruby list_step_definitions.rb`
    Then it should pass with JSON:
      """
      [
        {
          "source": {"expression": "foo", "type": "regular expression"},
          "regexp": {"source": "foo", "flags": "i"}
        },
        {
          "source": {"expression": "b.r", "type": "regular expression"},
          "regexp": {"source": "b.r", "flags": "mx"}
        }
      ]
      """

  Scenario: Non-default directory structure
    Given a file named "my_weird/place/steps.rb" with:
      """
      Given(/foo/)  { }
      Given(/b.r/x) { }
      """
    And a file named "list_step_definitions.rb" with:
      """
      require 'cucumber'
      puts Cucumber::StepDefinitions.new(:autoload_code_paths => ['my_weird']).to_json
      """
    When I run `bundle exec ruby list_step_definitions.rb`
    Then it should pass with JSON:
      """
      [
        {
          "source": {"expression": "foo", "type": "regular expression"},
          "regexp": {"source": "foo", "flags": ""}
        },
        {
          "source": {"expression": "b.r", "type": "regular expression"},
          "regexp": {"source": "b.r", "flags": "x"}
        }
      ]

      """
