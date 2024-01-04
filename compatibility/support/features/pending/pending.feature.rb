# frozen_string_literal: true

Given('an implemented non-pending step') do
  # no-op
end

Given('an implemented step that is skipped') do
  # no-op
end

Given('an unimplemented pending step') do
  pending('')
end
