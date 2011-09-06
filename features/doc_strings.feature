Feature: Doc strings

  Scenario: Plain text docstring
    Given a scenario with a step that looks like this:
      """gherkin
      Given I have a lot to say:
       \"\"\"
       One
       Two
       Three
       \"\"\"
      """
    And a step definition that looks like this:
      """ruby
      Given /say/ do |text|
        puts text
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      One
      Two
      Three
      """

  Scenario: Docstring with interesting content type
    Given a scenario with a step that looks like this:
      """gherkin
      Given I have some code for you:
       \"\"\"ruby
       puts "yo"
       \"\"\"
      """
    And a step definition that looks like this:
      """ruby
      Given /code/ do |text|
        puts text.content_type
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      ruby
      """

