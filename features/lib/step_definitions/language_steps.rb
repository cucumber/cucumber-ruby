# encoding: utf-8

Then(/^cucumber lists all the supported languages$/) do
  all_output.should include("Arabic")
  all_output.should include("български")
  all_output.should include("Pirate")
  all_output.should include("English")
  all_output.should include("日本語")
end
