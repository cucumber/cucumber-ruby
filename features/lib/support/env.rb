# frozen_string_literal: true

require 'aruba/cucumber'
require 'aruba/processes/in_process'
require 'aruba/processes/spawn_process'
require 'cucumber/cli/main'

Before do
  next unless RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
  aruba_dir = File.join('.', 'tmp', 'aruba')
  Dir.entries(aruba_dir).each do |entry|
    next if entry.start_with?('.')
    FileUtils.remove_entry_secure(File.join(aruba_dir, entry), force: true)
  end
end

Before('@spawn') do
  aruba.config.command_launcher = :spawn
  aruba.config.main_class = NilClass
end

Before('not @spawn') do
  aruba.config.command_launcher = :in_process
  aruba.config.main_class = Cucumber::Cli::Main
end

Before do
  # Set a longer timeout for aruba, and a really long one if running on JRuby
  @aruba_timeout_seconds = Cucumber::JRUBY ? 60 : 15
end

# TODO: This probably shouldn't be used. To fix this we need to triage all of the
# file names created in tests, and ensure they are unique
Cucumber.use_legacy_autoloader = true
