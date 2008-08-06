Feature: Tree
  In order to have more robust Java software
  I want to use Cucumber against Java classes

  Scenario: Use java.util.TreeSet
    Given I have an empty set
    When I add hello
    And I add world
    Then the contents should be hello world
