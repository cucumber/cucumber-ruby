require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  if RSpec::Mocks::Version::STRING.split('.').first.to_i > 2
    RSpec::Mocks.setup
  else
    RSpec::Mocks.setup(self)
  end
end

After do
  begin
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end
end
