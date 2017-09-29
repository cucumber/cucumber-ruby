Feature: Parameter Types

  Parameter Types allow you to convert primitive string arguments captured in step definitions
  into more meaningful data types.

  Background:
    Let's just create a simple feature for testing out parameter types.
    We also have a Person class that we need to be able to build.

    Given a file named "features/foo.feature" with:
      """
      Feature:
        Scenario:
          Given Joe has gone home
          When Sally contacts Joe
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      # It works with Regular Expressions
      Given /([A-Z]\w+) has gone home/ do |person|
        expect(person.name).to eq 'Joe'
      end

      # It works with Cucumber Expressions too
      When "{person} contacts {person}" do |contacter, contactee|
        expect(contacter.name).to eq 'Sally'
        expect(contactee.name).to eq 'Joe'
      end
      """
    And a file named "features/support/env.rb" with:
      """
      class Person
        attr_reader :name

        def initialize(name)
          @name = name
        end
      end
      """

  Scenario: Parameter type defined with ParameterType method
    This is the most basic way to use a parameter type.

    Given a file named "features/support/parameter_types.rb" with:
      """
      ParameterType(
        name: 'person',
        regexp: /[A-Z]\w+/,
        transformer: -> (name) { Person.new(name) }
      )
      """
    When I run `cucumber features/foo.feature`
    Then it should pass

    Scenario: Parameter type defined with ParameterType method
      If your parameter type's `regexp` is very general, you can tell
      Cucumber not to suggest its use in snippets:

    Given a file named "features/support/parameter_types.rb" with:
      """
      ParameterType(
        name: 'person',
        regexp: /[A-Z]\w+/,
        transformer: -> (name) { Person.new(name) },
        use_for_snippets: false
      )
      """
    When I run `cucumber features/foo.feature`
    Then it should pass
