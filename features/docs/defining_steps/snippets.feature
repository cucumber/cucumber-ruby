Feature: Snippets

  Cucumber helpfully prints out any undefined step definitions as a code
  snippet suggestion, which you can then paste into a step definitions
  file of your choosing.

  Scenario: Cucumber doesn't know what language, and defaults to Ruby
    Given a file named "features/x.feature" with:
      """
      Feature: X
        Scenario: Y
          Given Z
          Given Q
      """
    When I run `cucumber features`
    Then the stderr should not contain anything
    And it should pass with:
      """
      You can implement step definitions for undefined steps with these snippets:

      Given(/^Z$/) do
        pending # express the regexp above with the code you wish you had
      end

      Given(/^Q$/) do
        pending # express the regexp above with the code you wish you had
      end

      If you want snippets in a different programming language,
      just make sure a file with the appropriate file extension
      exists where cucumber looks for step definitions.


      """

  Scenario: Snippet for undefined step with a pystring
    Given a file named "features/undefined_steps.feature" with:
      """
      Feature:
      Scenario: pystring
        Given a pystring
        \"\"\"
          example with <html> entities
        \"\"\"
      """
    When I run `cucumber features/undefined_steps.feature -s`
    Then the output should contain:
      """
      Given(/^a pystring$/) do |string|
        pending # express the regexp above with the code you wish you had
      end
      """

  Scenario: Snippet for undefined step with a step table
    Given a file named "features/undefined_steps.feature" with:
      """
      Feature:
      Scenario: table
        Given a table
          | table |
          |example|
      """
    When I run `cucumber features/undefined_steps.feature -s`
    Then the output should contain:
      """
      Given(/^a table$/) do |table|
        # table is a Cucumber::Ast::Table
        pending # express the regexp above with the code you wish you had
      end
      """
