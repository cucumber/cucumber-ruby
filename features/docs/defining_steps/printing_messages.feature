Feature: Pretty formatter - Printing messages

  When you want to print to Cucumber's output, call `log` from
  a step definition. Cucumber will grab the output and print it via
  the formatter that you're using.

  Your message will be printed out after the step has run.

  Background:
    Given the standard step definitions
    And a file named "features/step_definitions/log_steps.rb" with:
      """
      Given /^I use log with text "(.*)"$/ do |ann|
        log(ann)
      end

      Given /^I use multiple logs$/ do
        log("Multiple")
        log("Announce\nMe")
      end

      Given /^I use message (.+) in line (.+) (?:with result (.+))$/ do |ann, line, result|
        log("Last message") if line == "3"
        log("Line: #{line}: #{ann}")
        fail if result =~ /fail/i
      end

      Given /^I use log and step fails$/ do
        log("Announce with fail")
        fail
      end

      Given /^I log the world$/ do
        log(self.to_s)
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature:

        Scenario:
          Given I use log with text "Ann"
          And this step passes

        Scenario:
          Given I use multiple logs
          And this step passes

        Scenario Outline:
          Given I use message <ann> in line <line>

          Examples:
            | line | ann   |
            | 1    | anno1 |
            | 2    | anno2 |
            | 3    | anno3 |

        Scenario:
          Given I use log and step fails
          And this step passes

        Scenario Outline:
          Given I use message <ann> in line <line> with result <result>

          Examples:
            | line | ann   | result |
            | 1    | anno1 | fail   |
            | 2    | anno2 | pass   |
      """

    And a file named "features/log_world.feature" with:
      """
      Feature: log_world
        Scenario: log_world
          Given I log the world
      """

    # Don't know why, but we need to spawn this for JRuby otherwise it gives wierd errors
    @spawn
    Scenario: Delayed messages feature
      When I run `cucumber --quiet --format pretty features/f.feature`
      Then the stderr should not contain anything
      And the output should contain:
      """
      Feature: 

        Scenario: 
          Given I use log with text "Ann"
            Ann
          And this step passes

        Scenario: 
          Given I use multiple logs
            Multiple
            Announce
            Me
          And this step passes

        Scenario Outline: 
          Given I use message <ann> in line <line>

          Examples: 
            | line | ann   |
            | 1    | anno1 |
            | 2    | anno2 |
            | 3    | anno3 |

        Scenario: 
          Given I use log and step fails
            Announce with fail
             (RuntimeError)
            ./features/step_definitions/log_steps.rb:18:in `/^I use log and step fails$/'
            features/f.feature:21:in `I use log and step fails'
          And this step passes

        Scenario Outline: 
          Given I use message <ann> in line <line> with result <result>

          Examples: 
            | line | ann   | result |
            | 1    | anno1 | fail   |  Line: 1: anno1
             (RuntimeError)
            ./features/step_definitions/log_steps.rb:13:in `/^I use message (.+) in line (.+) (?:with result (.+))$/'
            features/f.feature:29:25:in `I use message anno1 in line 1 with result fail'
            | 2    | anno2 | pass   |  Line: 2: anno2
      """

    Scenario: Non-delayed messages feature (progress formatter)
      When I run `cucumber --format progress features/f.feature`
      Then the output should contain:
        """
        Ann
        ..
        Multiple
        
        Announce
        Me
        ..UUU
        Announce with fail
        F-
        Line: 1: anno1
        F
        Line: 2: anno2
        .
        """

