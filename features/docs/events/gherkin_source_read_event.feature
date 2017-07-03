Feature: Gherkin Source Read Event

  This event is fired when Cucumber reads a Gherkin document.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/GherkinSourceRead)
  for more information about the data available on this event.

  @todo-windows
  Scenario: Read two documents
    Given a file named "features/one.feature" with:
      """
      Feature: One
        This is the first feature

      """
    And a file named "features/two.feature" with:
      """
      Feature: Two
        This is the other feature

      """
    And a file named "features/support/events.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :gherkin_source_read do |event|
          config.out_stream.puts "path: #{event.path}"
          config.out_stream.puts "body:\n#{event.body}"
        end
      end
      """
    When I run `cucumber --dry-run`
    Then it should pass with:
      """
      path: features/one.feature
      body:
      Feature: One
        This is the first feature
      path: features/two.feature
      body:
      Feature: Two
        This is the other feature
      """

