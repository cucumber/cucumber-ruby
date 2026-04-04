# frozen_string_literal: true

ENV['CUCUMBER_COLORS'] = nil
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'simplecov_setup'
require 'cucumber'

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.before { Cucumber::Term::ANSIColor.coloring = true }
end
