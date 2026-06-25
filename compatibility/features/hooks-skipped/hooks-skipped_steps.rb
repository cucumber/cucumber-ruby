# frozen_string_literal: true

Before do
  # no-op
end

Before('@skip-before') do
  skip_this_scenario('')
end

Before do
  # no-op
end

When('a normal step') do
  # no-op
end

When('a step that skips') do
  skip_this_scenario('')
end

After do
  # no-op
end

After('@skip-after') do
  skip_this_scenario('')
end

After do
  # no-op
end
