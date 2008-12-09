require 'cucumber/cli' # Needed in order to run the feature with ruby

Feature %|Addition
  In order to avoid silly mistakes
  As a math idiot 
  I want to be told the sum of two numbers| do

  Scenario "Add two numbers" do
    Given "I have entered 50 into the calculator"
    And "I have entered 70 into the calculator"
    When "I add"
    Then "the result should be 120 on the screen"
    And "the result class should be Fixnum"
  end
  
  Table do |t|
    t   | "input_1" | "input_2" | "output" | "class"  | t
    # This is kind of dumb - but it illustrates how scenarios can be "generated" in code.
    10.times do |n|
      t | n         | n*2       | n*3      | Fixnum   | t
    end
  end
  
  ScenarioOutline "Add two numbers" do
    Given "I have entered <input_1> into the calculator"
    And "I have entered <input_2> into the calculator"
    When "I add"
    Then "the result should be <output> on the screen"
    And "the result class should be <class>"
  end
  
  Table do |t|
    t | "input_1" | "input_2" | "output" | "class"  | t
    10.times do |n|
      t | n         | n*2       | n*3      | Fixnum   | t
    end
  end
  
end
