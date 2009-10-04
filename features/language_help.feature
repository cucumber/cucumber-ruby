Feature: Language help
  In order to figure out the keywords to use for a language
  I want to be able to get help on the language from the CLI

  Scenario: Get help for English language
    When I run cucumber -l en help
    Then it should pass with
      """
      | name                | 'English'                |
      | native              | 'English'                |
      | encoding            | 'UTF-8'                  |
      | space_after_keyword | 'true'                   |
      | feature             | 'Feature'                |
      | background          | 'Background'             |
      | scenario            | 'Scenario'               |
      | scenario_outline    | 'Scenario Outline'       |
      | examples            | 'Examples' / 'Scenarios' |
      | given               | 'Given'                  |
      | when                | 'When'                   |
      | then                | 'Then'                   |
      | and                 | 'And'                    |
      | but                 | 'But'                    |

      """