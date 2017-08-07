Feature: Test Run Started Event

  This event is fired once all test cases have been filtered, just before
  the first one is executed.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/TestRunStarted) for more information about the data available on this event.

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
    And a file named "features/support/events.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :test_count do |event|
          config.out_stream.puts "test count"
          config.out_stream.puts event.test_cases.map(&:location)
        end
      end
      """

  @todo-windows
  Scenario: Run the test case
    When I run `cucumber -q -f progress`
    Then it should pass with:
      """
      turtle!
      .
      turtle!
      .test count
      features/bar.feature:2
      features/foo.feature:2
      """

  @todo-windows
  Scenario: Run the test case with the --count-first option
    When I run `cucumber --count-first -q -f progress`
    Then it should pass with:
      """
      test count
      features/bar.feature:2
      features/foo.feature:2

      turtle!
      .
      turtle!
      .
      """

