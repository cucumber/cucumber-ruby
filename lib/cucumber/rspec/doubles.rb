# frozen_string_literal: true

require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup
end

After do
  RSpec::Mocks.verify
ensure
  RSpec::Mocks.teardown
end
