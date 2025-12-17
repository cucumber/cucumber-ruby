# frozen_string_literal: true

BeforeAll do
  # no-op
end

BeforeAll do
  raise 'BeforeAll hook went wrong'
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
  # no-op
end
