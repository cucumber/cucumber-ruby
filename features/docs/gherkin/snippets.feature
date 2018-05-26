Feature: Generating snippets

  Scenario: Different types of snippets
    Given a file named "features/snippets.feature" with:
      """
      Feature: Snippets

        Scenario: So many snippets
          Given a user named "Fred"
          And a user named 'Joe' (yes, that Joe)
          When I write a step def with {escaped characters}
          Then everything should turn out fine
      """
    When I run `cucumber features/snippets.feature`
    Then it should pass with:
      """
      You can implement step definitions for undefined steps with these snippets:

      Given('a user named {string}') do |string|
        pending # Write code here that turns the phrase above into concrete actions
      end

      Given('a user named {string} \(yes, that Joe)') do |string|
        pending # Write code here that turns the phrase above into concrete actions
      end

      When('I write a step def with \{escaped characters}') do
        pending # Write code here that turns the phrase above into concrete actions
      end

      Then('everything should turn out fine') do
        pending # Write code here that turns the phrase above into concrete actions
      end
      """