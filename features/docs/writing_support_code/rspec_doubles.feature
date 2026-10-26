Feature: RSpec doubles

  Requiring `cucumber/rspec/doubles` makes rspec-mocks available in step definitions. Doubles and stubs are reset
  after each scenario, and a message expectation that was not met fails the scenario.

  Scenario: Stubs are reset between scenarios and unmet expectations fail
    Given a file named "features/support/env.rb" with:
      """
      require 'cucumber/rspec/doubles'
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      class Greeter
        def self.greeting = 'hello'
      end

      Given('the greeting is stubbed') do
        allow(Greeter).to receive(:greeting).and_return('stubbed')
      end

      Given('a greeting is expected') do
        expect(Greeter).to receive(:greeting)
      end

      Then('the greeting is {string}') do |greeting|
        expect(Greeter.greeting).to eq(greeting)
      end
      """
    And a file named "features/doubles.feature" with:
      """
      Feature: Doubles

        Scenario: Stubbed
          Given the greeting is stubbed
          Then the greeting is "stubbed"

        Scenario: No longer stubbed
          Then the greeting is "hello"

        Scenario: Unmet expectation
          Given a greeting is expected
      """
    When I run `cucumber features/doubles.feature`
    Then it should fail with:
      """
      Failing Scenarios:
      cucumber features/doubles.feature:10 # Scenario: Unmet expectation

      3 scenarios (1 failed, 2 passed)
      """
    And the output should contain "expected: 1 time with any arguments"
