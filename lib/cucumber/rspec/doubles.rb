# frozen_string_literal: true

require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup(self)
end

After do
  RSpec::Mocks.teardown
end
