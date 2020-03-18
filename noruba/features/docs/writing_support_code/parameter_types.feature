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

  Scenario: Parameter type delegating to World
    Given a file named "features/support/parameter_types.rb" with:
      """
      ParameterType(
        name: 'person',
        regexp: /[A-Z]\w+/,
        transformer: -> (name) { make_person(name) },
        use_for_snippets: false
      )
      """
    Given a file named "features/support/world.rb" with:
      """
      module MyWorld
        def make_person(name)
          Person.new(name)
        end
      end
      World(MyWorld)
      """
    When I run `cucumber features/foo.feature`
    Then it should pass

  Scenario: Parameter type with group nested in optional group
    Given a file named "features/support/parameter_types.rb" with:
      """
      ParameterType(
        name: "Employer",
        regexp: /Employer(?: "([^"]*)")?/,
        transformer: -> (name = nil) do
          name || 'Unnamed'
        end
      )
      
      ParameterType(
        name: 'person',
        regexp: /[A-Z]\w+/,
        transformer: -> (name) { Person.new(name) }
      )
      """
    And a file named "features/employees.feature" with:
      """
      Feature: Employees
        Scenario: Unnamed
          Given the Employer
          Then the name should be "Unnamed"
      """
    And a file named "features/step_definitions/employee_steps.rb" with:
      """
      Given "the {Employer}" do |name|
        @name = name
      end

      Given "the name should be {string}" do |name|
        expect(name).to eq(@name)
      end
      """
    When I run `cucumber features/employees.feature --strict`
    Then it should pass
