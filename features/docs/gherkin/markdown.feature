Feature: Markdown

  Cucumber 2.0 will pull Gherkin snippets out of Markdown files, compile and run them.
  
  Scenario: Markdown file with a single scenario in it
    Given a file named "features/readme.md" with:
      """
      # My amazing project
      
      Here is some documentation about my amazing project. Within this documentation, I'm going to include
      some gherkin:

      ```gherkin
      Feature: Test Feature
      
        Scenario: Test Scenario
          Given passing
      ```

      ...and Cucumber will run it for me.
      """
    When I run `cucumber features`
    Then it should pass with:
      """
      Feature: Test Feature

        Scenario: Test Scenario
          Given passing
      """
