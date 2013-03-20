Feature: Set up a default load path

  Scenario: ./lib is included in the $LOAD_PATH
    Given a file named "features/support/env.rb" with:
      """
      require 'something'
      """
    And a file named "lib/something.rb" with:
      """
      class Something
      end
      """
    When I run `cucumber`
    Then it should pass
