Feature: Transforms

  If you see certain phrases repeated over and over in your step definitions, you can
  use transforms to factor out that duplication, and make your step definitions simpler.
  
  Background:
    Let's just create a simple feature for testing out Transforms.
    We also have a Person class that we need to be able to build.
    
    Given a file named "features/foo.feature" with:
      """
      Feature:
        Scenario:
          Given a Person aged 15 with blonde hair
      """
    And a file named "features/support/person.rb" with:
      """
      class Person
        attr_accessor :age
      
        def to_s
          "I am #{age} years old"
        end
      end
      """

  Scenario: Basic Transform
    This is the most basic way to use a transform. Notice that the regular
    expression is pretty much duplicated.
    
    And a file named "features/step_definitions/steps.rb" with:
      """
      Transform(/a Person aged (\d+)/) do |age|
        person = Person.new
        person.age = age.to_i
        person
      end
      
      Given /^(a Person aged \d+) with blonde hair$/ do |person|
        expect(person.age).to eq 15
      end
      """
    When I run `cucumber features/foo.feature`
    Then it should pass
  
  Scenario: Re-use Transform's Regular Expression
    If you keep a reference to the transform, you can use it in your
    regular expressions to avoid repeating the regular expression.

    And a file named "features/step_definitions/steps.rb" with:
      """
      A_PERSON = Transform(/a Person aged (\d+)/) do |age|
        person = Person.new
        person.age = age.to_i
        person
      end

      Given /^(#{A_PERSON}) with blonde hair$/ do |person|
        expect(person.age).to eq 15
      end
      """
    When I run `cucumber features/foo.feature`
    Then it should pass
