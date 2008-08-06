require 'cucumber/cli' # Needed in order to run the story with ruby

Feature %|Addition
  As a math idiot 
  I want to be told the sum of two numbers
  So that I don't make silly mistakes| do

  Scenario "50+70" do
    Given "I have entered 50 into the calculator"
    And "I have entered 70 into the calculator"
    When "I add"
    Then "the result should be 120 on the screen"
    And "the result class should be Float"
  end
  
  Table do |t|
    t | "input_1" | "input_2" | "output" | "class"  | t
    t | "20"      | "30"      | "50"     | "Number" | t
    t | 2         | 5         | 7        | Fixnum   | t
    t | "20"      | "40"      | "80"     | "Number" | t
  end
end
