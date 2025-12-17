# frozen_string_literal: true

BeforeAll do
  attach('Attachment from BeforeAll hook', 'text/plain')
end

When('a step passes') do
  # no-op
end

AfterAll do
  attach('Attachment from AfterAll hook', 'text/plain')
end
