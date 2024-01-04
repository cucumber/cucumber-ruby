Feature: Examples Tables
  Sometimes it can be desirable to run the same scenario multiple times with
  different data each time - this can be done by placing an Examples table underneath
  a Scenario, and use <placeholders> in the Scenario which match the table headers.

  Scenario Outline: Eating cucumbers
    Given there are <start> cucumbers
    When I eat <eat> cucumbers
    Then I should have <left> cucumbers

    @passing
    Examples: These are passing
      | start | eat | left |
      |    12 |   5 |    7 |
      |    20 |   5 |   15 |

    @failing
    Examples: These are failing
      | start | eat | left |
      |    12 |  20 |    0 |
      |     0 |   1 |    0 |

    @undefined
    Examples: These are undefined because the value is not an {int}
      | start | eat    | left  |
      |    12 | banana |    12 |
      |     0 |      1 | apple |
