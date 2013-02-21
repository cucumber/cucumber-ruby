Feature: Nested Steps with either table or doc string

  Background:
    Given a scenario with a step that looks like this:
      """gherkin
      Given two turtles
      """

  Scenario: Use #step with table
    Given a step definition that looks like this:
      """ruby
      Given /turtles:/ do |table|
        table.hashes.each do |row|
          puts row[:name]
        end
      end
      """
    And a step definition that looks like this:
      """ruby
      Given /two turtles/ do
        step %{turtles:}, table(%{
        | name      |
        | Sturm     |
        | Liouville |
        })
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      Sturm

      Liouville

      """

  Scenario: Use #step with docstring
    Given a step definition that looks like this:
      """ruby
      Given /two turtles/ do
        step %{turtles:}, "Sturm and Lioville"
      end
      """
    And a step definition that looks like this:
      """ruby
      Given /turtles:/ do |text|
        puts text
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      Sturm and Lioville
      """

  Scenario: Use #step with docstring and content-type
    Given a step definition that looks like this:
      """ruby
      Given /two turtles/ do
        step %{turtles:}, doc_string('Sturm and Lioville','math')
      end
      """
    And a step definition that looks like this:
      """ruby
      Given /turtles:/ do |text|
        puts text.content_type
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      math
      """
