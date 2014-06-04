require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks::setup(self)
end

After do
  begin
    RSpec::Mocks::verify
  ensure
    RSpec::Mocks::teardown
  end
end
