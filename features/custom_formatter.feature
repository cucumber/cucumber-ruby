Feature: Custom Formatter

  Scenario: count tags
    When I run cucumber --format Tag::Count features
    Then it should fail with
      """
      | four | lots | one | three | two |
      | 1    | 1    | 1   | 2     | 1   |

      """
    