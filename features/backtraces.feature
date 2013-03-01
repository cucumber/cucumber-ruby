Feature: Backtraces
  In order to discover errors quickly
  As a cuker
  I want to see backtraces for failures

  Background:
    Given a file named "features/failing_hard.feature" with:
      """
      Feature: Sample
        Scenario: Example
          Given failing
      """

  @jruby
  Scenario: Backtraces enabled
    Given a file named "features/step_definitions/steps.rb" with:
      """
      require 'java'
      java_import 'java.util.Collections'

      Given /^failing$/ do
        Collections.empty_list.add 1
      end
      """
    When I run `cucumber features/failing_hard.feature`
    Then it should fail with:
      """
      Feature: Sample

        Scenario: Example # features/failing_hard.feature:2
          Given failing   # features/step_definitions/steps.rb:4
            java.lang.UnsupportedOperationException: null (NativeException)
            java/util/AbstractList.java:131:in `add'
            java/util/AbstractList.java:91:in `add'
      """

  @not-jruby
  Scenario: Ruby backtraces
    Given a file named "game.rb" with:
      """
      class Game
        def start; end
      end
      """
    And a file named "features/start.feature" with:
      """
      Feature:
        Scenario:
          When I start the game
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      require File.dirname(__FILE__) + '/../../game'
      When /start/ do
        Game.new.start('a spurious argument')
      end
      """
    When I run `cucumber`
    Then it should fail with:
      """
      Feature: 
      
        Scenario:               # features/start.feature:2
          When I start the game # features/step_definitions/steps.rb:2
            wrong number of arguments (1 for 0) (ArgumentError)
            ./game.rb:2:in `start'
            ./features/step_definitions/steps.rb:3:in `/start/'
            features/start.feature:3:in `When I start the game'
      """

