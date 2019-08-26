@needs-many-fonts
Feature: i18n

  It's possible to ask cucumber which keywords are used for any
  particular language by running:

  `cucumber --i18n-keywords <LANG>`

  This will print a table showing all the different words we use for
  that language, to allow you to easily write features in any language
  you choose.

  Scenario: Get help for Portuguese language
    When I run `cucumber --i18n-keywords pt`
    Then it should pass with:
      """
        | feature          | "Funcionalidade", "Característica", "Caracteristica"                                         |
        | background       | "Contexto", "Cenário de Fundo", "Cenario de Fundo", "Fundo"                                  |
        | scenario         | "Exemplo", "Cenário", "Cenario"                                                              |
        | scenario_outline | "Esquema do Cenário", "Esquema do Cenario", "Delineação do Cenário", "Delineacao do Cenario" |
        | examples         | "Exemplos", "Cenários", "Cenarios"                                                           |
        | given            | "* ", "Dado ", "Dada ", "Dados ", "Dadas "                                                   |
        | when             | "* ", "Quando "                                                                              |
        | then             | "* ", "Então ", "Entao "                                                                     |
        | and              | "* ", "E "                                                                                   |
        | but              | "* ", "Mas "                                                                                 |
        | given (code)     | "Dado", "Dada", "Dados", "Dadas"                                                             |
        | when (code)      | "Quando"                                                                                     |
        | then (code)      | "Então", "Entao"                                                                             |
        | and (code)       | "E"                                                                                          |
        | but (code)       | "Mas"                                                                                        |

      """

  Scenario: List languages
    When I run `cucumber --i18n-languages`
    Then cucumber lists all the supported languages

  Scenario: Seek help for invalid language
    When I run `cucumber --i18n-keywords foo`
    Then the output includes the message "Invalid language 'foo'"
    And cucumber lists all the supported languages
