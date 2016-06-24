# @wip
Feature: Specifying a different spoken language for runs

  An

    -L, --language LANGUAGE

  option that allows users to switch to a different language
  without adding a language header to each feature file

  Scenario: An unknown language specified
    Given an empty file named "features/whatever.feature"
    When I run `cucumber --language foo`
    Then it should fail with:
      """
      Sorry, we don't recognize this language.
      Try 'cucumber --i18n help', and look up the abbreviation
      of the language you want to use in the list.
      """

  Scenario: Specified language agrees with the language in use
    Given a file named "features/cash_withdrawal.feature" with:
      """
      フィーチャ: 現金引き出し
        シナリオ: 信用口座から現金を引き出すことができます
          前提私は自分の口座に¥10000を貯金しました
      """
    When I run `cucumber -L ja`
    Then it should pass

  Scenario: Specified language does not agree with the language in use
    Given a file named "features/cash_withdrawal.feature" with:
      """
      Feature: Cash withdrawal
        Scenario: Successful withdrawal from an account in credit
          Given I have deposited ¥10000 in my account
      """
    When I run `cucumber -L ja`
    Then it should raise Parser errors

  Scenario: A language header is present
    Given a file named "features/cash_withdrawal.feature" with:
      """
      # language: en
      Feature: Cash withdrawal
        Scenario: Successful withdrawal from an account in credit
          Given I have deposited ¥10000 in my account
      """
    When I run `cucumber -L ja`
    Then it should pass
