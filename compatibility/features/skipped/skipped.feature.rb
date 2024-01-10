# frozen_string_literal: true

Before('@skip') do
  skip_this_scenario('')
end

Given('a step that does not skip') do
  # no-op
end

Given('a step that is skipped') do
  # no-op
end

Given('I skip a step') do
  skip_this_scenario('')
end
