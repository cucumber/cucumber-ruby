@proposed
Feature: Cucumber Server
  To prevent waiting for Rails and other large Ruby applications to load their environments for each feature run
  Cucumber ships with a DRB server that loads up the environment once and allows cucumber commands to be issued to it.

  Scenario: Basic Feature Run
    Given a standard Cucumber project directory structure
    And a file named "features/support/env.rb" with:
      """
      require 'rubygems'
      require 'spork'

      Spork.prefork do
        puts "I'm loading all the heavy stuff..."
      end

      Spork.each_run do
        puts "I'm loading the stuff just for this run..."
      end
      """
    And a file named "features/sample.feature" with:
      """
      Feature: Sample
        Scenario: this is a test
          Given I am just testing stuff
      """
    And I am running "cucumber_server" in the background

    When I run cucumber features/sample.feature --drb
    Then it should pass
    And the output should contain
      """
      I'm loading the stuff just for this run...
      """
    And the output should not contain
      """
      I'm loading all the heavy stuff...
      """
