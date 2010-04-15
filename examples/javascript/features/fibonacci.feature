Feature: Fibonacci
  In order to calculate super fast fibonacci series
  As a Javascriptist
  I want to use Javascript for that

  Scenario Outline: Series
    When I ask Javascript to calculate fibonacci up to <n>
    Then it should give me <series>

    Examples:
      | n   | series                                 |
      | 1   | []                                     |
      | 2   | [1, 1]                                 |
      | 3   | [1, 1, 2]                              |
      | 4   | [1, 1, 2, 3]                           |
      | 6   | [1, 1, 2, 3, 5]                        |
      | 9   | [1, 1, 2, 3, 5, 8]                     |
      | 100 | [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89] |

  Scenario: Single series
    When I ask Javascript to calculate fibonacci up to 2
    Then it should give me:
    """
    [1, 1]
    """

  Scenario:
    When I ask Javascript to calculate fibonacci up to 2
    Then it should contain:
    | cell 1 | cell 2 |
    |   1    |   1    |
