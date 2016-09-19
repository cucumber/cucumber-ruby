@needs-many-fonts
Feature: Getting info of supported languages

  Ask Cucumber for a list of supported spoken languages by running:

    cucumber --i18n help

  Ask Cucumber for the keywords of a supported language by running:

    cucumber --i18n LANG

  Scenario: Look up the language code of a supported language
    When I run `cucumber --i18n help`
    Then Cucumber displays the language table

  Scenario: Need help for keywords of Portuguese
    When I run `cucumber --i18n pt`
    Then it should pass with:
      """
        | feature          | "Funcionalidade", "Característica", "Caracteristica"                                         |
        | background       | "Contexto", "Cenário de Fundo", "Cenario de Fundo", "Fundo"                                  |
        | scenario         | "Cenário", "Cenario"                                                                         |
        | scenario_outline | "Esquema do Cenário", "Esquema do Cenario", "Delineação do Cenário", "Delineacao do Cenario" |
        | examples         | "Exemplos", "Cenários", "Cenarios"                                                           |
        | given            | "* ", "Dado ", "Dada ", "Dados ", "Dadas "                                                   |
        | when             | "* ", "Quando "                                                                              |
        | then             | "* ", "Então ", "Entao "                                                                     |
        | and              | "* ", "E "                                                                                   |
        | but              | "* ", "Mas "                                                                                 |
      """

  Scenario: Seek help for invalid language
    When I run `cucumber --i18n foo`
    Then it should fail with:
      """
      Invalid language 'foo'. Available languages are:
      """
    And Cucumber displays the language table
