# frozen_string_literal: true

Before('@passing-hook') do
  # no-op
end

Before('@fail-before') do
  raise 'Exception in conditional hook'
end

When('a step passes') do
  # no-op
end

After('@passing-hook') do
  # no-op
end

After('@fail-after') do
  raise 'Exception in conditional hook'
end
