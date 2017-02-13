Feature: Test Run Starting Event

  This event is fired once all test cases have been filtered, just before
  the first one is executed.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/TestRunStarting) for more information about the data available on this event.

  Background:
    Given the standard step definitions
    And a file named "features/foo.feature" with:
      """
      Feature: Foo
        Scenario:
          Given a passing step
      """
    And a file named "features/bar.feature" with:
      """
      Feature: Foo
        Scenario:
          Given a passing step
      """
    And a file named "features/support/events.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :test_run_starting do |event|
          config.out_stream.puts "test run starting"
          config.out_stream.puts event.test_cases.map(&:location)
        end
      end
      """

  Scenario: Run the test case
    When I run `cucumber -q`
    Then it should pass with:
      """
      test run starting
      features/bar.feature:2
      features/foo.feature:2
      """

