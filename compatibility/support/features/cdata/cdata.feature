Feature: cdata
  Cucumber xml formatters should be able to handle xml cdata elements

  Scenario: cdata
    Given I have 42 <![CDATA[cukes]]> in my belly
