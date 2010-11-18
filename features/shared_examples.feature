Feature: Shared Examples in Scenario Outlines
  In order to keep scenarios DRY
  As a scenario author
  I want a way for several Scenario Outlines to use the same Examples

  Background:
    Given a file named "features/login_steps.rb" with:
      """
      When /^I login as "(.+)" with password "(.+)"$/ do |user, password|
        if user == 'bogus' || password == 'bogus'
          @expect = 'fail'
        else
          @expect = 'succeed'
        end
      end

      Then /^login should (succeed|fail)$/ do |status|
        @expect.should == status
      end
      """

  Scenario: All Scenario Outlines can share the same Examples
    Given a file named "features/login.feature" with:
      """
      Feature: Login

        Scenario Outline: Valid login
          When I login as "<user>" with password "<password>"
          Then login should succeed

        Scenario Outline: Invalid username
          When I login as "bogus" with password "<password>"
          Then login should fail

        Scenario Outline: Invalid password
          When I login as "<user>" with password "bogus"
          Then login should fail

        Examples:
          | user  | password |
          | alice | 111      |
          | bob   | 222      |
          | chuck | 333      |
          | david | 444      |
      """
    When I run cucumber -q features/login.feature
    Then it should pass with
      """
      12 scenarios (12 passed)
      24 steps (24 passed)
      """

  Scenario: Groups of Scenario Outlines can share group Examples
    Given a file named "features/login.feature" with:
      """
      Feature: Login

        Scenario Outline: Valid superhero login
          When I login as "<user>" with password "<password>"
          Then login should succeed

        Scenario Outline: Invalid superhero username
          When I login as "bogus" with password "<password>"
          Then login should fail

        Scenario Outline: Invalid superhero password
          When I login as "<user>" with password "bogus"
          Then login should fail

        Examples:
          | user     | password |
          | superman | 123      |
          | spidey   | 456      |


        Scenario Outline: Valid supervillain login
          When I login as "<user>" with password "<password>"
          Then login should succeed

        Scenario Outline: Invalid supervillain username
          When I login as "bogus" with password "<password>"
          Then login should fail

        Scenario Outline: Invalid supervillain password
          When I login as "<user>" with password "bogus"
          Then login should fail

        Examples:
          | user        | password |
          | lexluthor   | 123      |
          | greengoblin | 456      |

      """
    When I run cucumber -q features/login.feature
    Then it should pass with
      """
      12 scenarios (12 passed)
      24 steps (24 passed)
      """

