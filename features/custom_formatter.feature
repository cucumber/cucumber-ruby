Feature: Custom Formatter

  Scenario: count tags
    When I run cucumber --format Cucumber::Formatter::TagCloud features
    Then it should fail with
      """
      | after_file | background_tagged_before_on_outline | four | lots | one | sample_four | sample_one | sample_three | sample_two | three | two |
      | 1          | 1                                   | 1    | 1    | 1   | 2           | 1          | 2            | 1          | 2     | 1   |

      """
    