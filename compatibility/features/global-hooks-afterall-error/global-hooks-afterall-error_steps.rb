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

AfterAll do
  # no-op
end

AfterAll do
  raise 'AfterAll hook went wrong'
end

AfterAll do
  # no-op
end
