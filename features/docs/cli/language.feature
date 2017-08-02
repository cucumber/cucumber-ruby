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
      Invalid language 'foo'. Available languages are:

        | af        | Afrikaans           | Afrikaans         |
        | am        | Armenian            | հայերեն           |
        | ar        | Arabic              | العربية           |
        | bg        | Bulgarian           | български         |
        | bm        | Malay               | Bahasa Melayu     |
        | bs        | Bosnian             | Bosanski          |
        | ca        | Catalan             | català            |
        | cs        | Czech               | Česky             |
        | cy-GB     | Welsh               | Cymraeg           |
        | da        | Danish              | dansk             |
        | de        | German              | Deutsch           |
        | el        | Greek               | Ελληνικά          |
        | em        | Emoji               | 😀                 |
        | en        | English             | English           |
        | en-Scouse | Scouse              | Scouse            |
        | en-au     | Australian          | Australian        |
        | en-lol    | LOLCAT              | LOLCAT            |
        | en-old    | Old English         | Englisc           |
        | en-pirate | Pirate              | Pirate            |
        | eo        | Esperanto           | Esperanto         |
        | es        | Spanish             | español           |
        | et        | Estonian            | eesti keel        |
        | fa        | Persian             | فارسی             |
        | fi        | Finnish             | suomi             |
        | fr        | French              | français          |
        | ga        | Irish               | Gaeilge           |
        | gj        | Gujarati            | ગુજરાતી           |
        | gl        | Galician            | galego            |
        | he        | Hebrew              | עברית             |
        | hi        | Hindi               | हिंदी             |
        | hr        | Croatian            | hrvatski          |
        | ht        | Creole              | kreyòl            |
        | hu        | Hungarian           | magyar            |
        | id        | Indonesian          | Bahasa Indonesia  |
        | is        | Icelandic           | Íslenska          |
        | it        | Italian             | italiano          |
        | ja        | Japanese            | 日本語               |
        | jv        | Javanese            | Basa Jawa         |
        | kn        | Kannada             | ಕನ್ನಡ             |
        | ko        | Korean              | 한국어               |
        | lt        | Lithuanian          | lietuvių kalba    |
        | lu        | Luxemburgish        | Lëtzebuergesch    |
        | lv        | Latvian             | latviešu          |
        | mn        | Mongolian           | монгол            |
        | nl        | Dutch               | Nederlands        |
        | no        | Norwegian           | norsk             |
        | pa        | Panjabi             | ਪੰਜਾਬੀ            |
        | pl        | Polish              | polski            |
        | pt        | Portuguese          | português         |
        | ro        | Romanian            | română            |
        | ru        | Russian             | русский           |
        | sk        | Slovak              | Slovensky         |
        | sl        | Slovenian           | Slovenski         |
        | sr-Cyrl   | Serbian             | Српски            |
        | sr-Latn   | Serbian (Latin)     | Srpski (Latinica) |
        | sv        | Swedish             | Svenska           |
        | ta        | Tamil               | தமிழ்             |
        | th        | Thai                | ไทย               |
        | tl        | Telugu              | తెలుగు            |
        | tlh       | Klingon             | tlhIngan          |
        | tr        | Turkish             | Türkçe            |
        | tt        | Tatar               | Татарча           |
        | uk        | Ukrainian           | Українська        |
        | ur        | Urdu                | اردو              |
        | uz        | Uzbek               | Узбекча           |
        | vi        | Vietnamese          | Tiếng Việt        |
        | zh-CN     | Chinese simplified  | 简体中文              |
        | zh-TW     | Chinese traditional | 繁體中文              |
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
    Then it should raise parser errors

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
