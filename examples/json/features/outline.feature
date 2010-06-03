Feature: A scenario outline

  Scenario Outline:
    Given I add <a> and <b>
    Then I the result should be <c>

    Examples:
      | a   | b   | c |
      | 1   | 2   | 3 |
      | 2   | 3   | 4 |