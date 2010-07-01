require 'rspec/core'

RSpec.configuration.configure_mock_framework
World(RSpec::Core::MockFrameworkAdapter)

Before do
  _setup_mocks
end

After do
  _verify_mocks
  _teardown_mocks
end