@wip
Feature: Test Case Started Event

  This event is fired just before each scenario or scenario outline example row
  (generally named a Test Case) starts to be executed. This event is read-only.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/TestCaseStarted) for more information about the data available on this event and the result object.

  Background:
    Given the standard step definitions
    And a file named "features/test.feature" with:
      """
      @feature
      Feature: A feature

        @scenario
        Scenario: A passing scenario
          Given this is a step
      """
    And a file named "features/support/events.rb" with:
      """
      stdout = nil
      AfterConfiguration do |config|
        stdout = config.out_stream # make sure all the `puts` calls can write to the same output
        config.on_event :test_case_started do |event|
          stdout.puts "before"
          stdout.puts event.test_case.tags.map(&:name)
        end
        config.on_event :test_case_finished do |event|
          stdout.puts "after"
        end
      end

      Given(/this is a step/) do 
      end

      """

  Scenario: Run the test case
    When I run `cucumber -q`
    Then it should pass with:
      """
      before
      @feature
      @scenario
      @feature
      Feature: A feature
      
        @scenario
        Scenario: A passing scenario
          Given this is a step
      after
      """

