Feature: Snippets

  Cucumber helpfully prints out any undefined step definitions as a code
  snippet suggestion, which you can then paste into a step definitions
  file of your choosing.

  Scenario: Snippet for undefined step with a Doc String
    Given a file named "features/undefined_steps.feature" with:
      """
      Feature:
        Scenario: Doc String
          Given a Doc String
          \"\"\"
            example with <html> entities
          \"\"\"
          When 1 simple when step
          And another "when" step
          Then a simple then step
      """
    When I run `cucumber features/undefined_steps.feature -s`
    Then the output should contain:
      """
      Given('a Doc String') do |doc_string|
        pending # Write code here that turns the phrase above into concrete actions
      end

      When('{int} simple when step') do |int|
      # When('{float} simple when step') do |float|
        pending # Write code here that turns the phrase above into concrete actions
      end

      When('another {string} step') do |string|
        pending # Write code here that turns the phrase above into concrete actions
      end

      Then('a simple then step') do
        pending # Write code here that turns the phrase above into concrete actions
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
      Given('a table') do |table|
        # table is a Cucumber::MultilineArgument::DataTable
        pending # Write code here that turns the phrase above into concrete actions
      end
      """

  Scenario: Snippet for undefined step with multiple params
    Given a file named "features/undefined_steps.feature" with:
      """
      Feature:
        Scenario: Send emails
          Given I send an email entitled "Hi from Cucumber" to john@example.org with content:
          \"\"\"
          Hello there!
          \"\"\"
      """
    And a file named "features/support/parameter_types.rb" with:
      """
      ParameterType(
        name: 'email_address',
        regexp: /([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)/,
        transformer: -> (email) { email }
      )
      """
    When I run `cucumber features/undefined_steps.feature -s`
    Then the output should contain:
      """
      Given('I send an email entitled {string} to {email_address} with content:') do |string, email_address, doc_string|
        pending # Write code here that turns the phrase above into concrete actions
      end
      """

  Scenario: Snippet for undefined step with undefined parameter type
    Given a file named "features/undefined_parameter_type.feature" with:
      """
      Feature:
        Scenario: Delayed flight
          Given leg LHR-OSL is cancelled
      """
    And a file named "features/steps.rb" with:
      """
      Given('leg {flight-leg} is cancelled') do |flight|
        log flight.to_s
      end
      """
    When I run `cucumber features/undefined_parameter_type.feature -s`
    Then the output should contain:
      """
      The parameter flight-leg is not defined. You can define a new one with:

      ParameterType(
        name:        'flight-leg',
        regexp:      /some regexp here/,
        type:        FlightLeg,
        # The transformer takes as many arguments as there are capture groups in the regexp,
        # or just one if there are none.
        transformer: ->(s) { FlightLeg.new(s) }
      )
      """
