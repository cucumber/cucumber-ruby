@proposed
Feature: Spork Integration
  To prevent waiting for Rails and other large Ruby applications to load their environments for each feature run
  Cucumber ships with a DRB client that can speak to Spork which loads up the environment once.

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
    And I am running "spork --cucumber" in the background

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
