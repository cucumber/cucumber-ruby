# frozen_string_literal: true

BeforeAll do
  # no-op
end

BeforeAll do
  # no-op
end

When('a step passes') do
  # no-op
end

When('a step fails') do
  raise 'Exception in step'
end

AfterAll do
  # no-op
end

AfterAll do
  # no-op
end
