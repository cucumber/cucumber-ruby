# frozen_string_literal: true

require 'aruba/cucumber'
require 'aruba/in_process'
require 'aruba/spawn_process'
require 'cucumber/cli/main'

Before('@spawn') do
  aruba.config.command_launcher = :spawn
  aruba.config.main_class = NilClass
end

Before('not @spawn') do
  aruba.config.command_launcher = :in_process
  aruba.config.main_class = Cucumber::Cli::Main
end

Before do
  # Make sure bin/cucumber runs with SimpleCov enabled
  # set_env('SIMPLECOV', 'true')

  # Set a longer timeout for aruba, and a really long one if running on JRuby
  @aruba_timeout_seconds = Cucumber::JRUBY ? 60 : 15
end
