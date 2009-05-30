@in_progress
Feature: DRb Server Integration
  To prevent waiting for Rails and other large Ruby applications to load their environments
  for each feature run Cucumber ships with a DRb client that can speak to a server which
  loads up the environment only once.

  Background: App with Spork support
              Spork is a gem that has a DRb server and the scenarios below use illustarate how to use it.
              However, any DRb server that adheres to the protocol that the client expects would work.

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

  Scenario: Feature Run with --drb flag
    Given I am running "spork cuc" in the background

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


  Scenario: Feature Run with --drb flag with no DRb server running
            Cucumber will fall back on running the features locally in this case.

    Given I am not running a DRb server in the background

    When I run cucumber features/sample.feature --drb
    Then it should pass
    And the output should contain
      """
      No DRb server is running. Running features locally:
      I'm loading all the heavy stuff...
      I'm loading the stuff just for this run...
      """
