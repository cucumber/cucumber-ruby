# frozen_string_literal: true

Before do
  # no-op
end

Before(name: 'A named hook') do
  # no-op
end

When('a step passes') do
  # no-op
end

When('a step fails') do
  raise 'Exception in step'
end

After do
  # no-op
end

After('@some-tag or @some-other-tag') do
  raise 'Exception in conditional hook'
end

After('@with-attachment') do
  attach(File.open("#{__dir__}/cucumber.svg"), 'image/svg+xml')
end
