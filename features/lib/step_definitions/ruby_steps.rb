# frozen_string_literal: true

When('I run the following Ruby code:') do |code|
  run_command_and_stop %(ruby -e "#{code}")
end
