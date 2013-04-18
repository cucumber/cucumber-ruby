@drb @wip-jruby @spawn
Feature: DRb Server Integration
  To prevent waiting for Rails and other large Ruby applications to load their environments
  for each feature run Cucumber ships with a DRb client that can speak to a server which
  loads up the environment only once.

  This regression test highlights bug related to DRb server arguments processing, for more
  details see https://github.com/cucumber/cucumber/issues/117

  Background: App with Spork support
    Spork is a gem that has a DRb server and the scenarios below illustrate how to use it.
    However, any DRb server that adheres to the protocol that the client expects would work.

    Given a directory without standard Cucumber project directory structure
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
    And a file named "config/cucumber.yml" with:
      """
      <%
      std_opts = "--format #{ENV['CUCUMBER_FORMAT'] || 'pretty'} --strict --tags ~@wip"
      %>
      default: --drb <%= std_opts %> features
      """
    And a file named "features/sample.feature" with:
      """
      # language: en
      Feature: Sample
        Scenario: this is a test
          Given I am just testing stuff
      """
    And a file named "features/step_definitions/all_your_steps_are_belong_to_us.rb" with:
    """
    Given /^I am just testing stuff$/ do
      # no-op
    end
    """

  Scenario: Single feature passing with '-r features' option
    Given I am running spork in the background
    When I run `cucumber features/sample.feature -r features --tags ~@wip`
    And it should pass with:
    """
    1 step (1 passed)
    """

  Scenario: Single feature passing without '-r features' option
    Given I am running spork in the background
    When I run `cucumber features/sample.feature --tags ~@wip`
    And it should pass with:
    """
    1 step (1 passed)
    """
