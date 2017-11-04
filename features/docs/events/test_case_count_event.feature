Feature: Test Case Count Event

  This event is fired only if a handler if registered for it. In that case it
  is fired once all test cases have been filtered, just before the first one
  is executed. Register a handler for this event delays the execution of any
  tese case until all test cases have been filtered.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/TestCaseCount) for more information about the data available on this event.

  Background:
    Given the standard step definitions
    And a file named "features/foo.feature" with:
      """
      Feature: Foo
        Scenario:
          Given a turtle
      """
    And a file named "features/bar.feature" with:
      """
      Feature: Foo
        Scenario:
          Given a turtle
      """
    And a step definition that looks like this:
      """ruby
      Given /a turtle/ do
        puts "turtle!"
      end
      """
    And a step definition that looks like this:
      """ruby
      Then /no test case count event has been sent/ do
        puts "turtle!"
      end
      """

  @todo-windows
  Scenario: Run the test case with a handler registered for the test case count event
     Given a file named "features/support/events.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :test_case_count do |event|
          config.out_stream.puts "test case count"
          config.out_stream.puts event.test_cases.map(&:location)
        end
      end
      """
    When I run `cucumber -q -f progress`
    Then it should pass with:
      """
      test case count
      features/bar.feature:2
      features/foo.feature:2

      turtle!
      .
      turtle!
      .
      """

