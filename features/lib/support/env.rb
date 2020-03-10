# frozen_string_literal: true

require 'aruba/cucumber'
require 'aruba/processes/in_process'
require 'aruba/processes/spawn_process'
require 'cucumber/cli/main'

def empty_directory(dir_path)
  Dir.entries(dir_path).each do |entry|
    next if ['.', '..'].include?(entry)
    FileUtils.remove_entry_secure(File.join(dir_path, entry), force: true)
  end
end

Before do
  next unless RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/

  aruba_dir = File.join('.', 'tmp', 'aruba')
  empty_directory(aruba_dir)

  unless Dir.empty?(aruba_dir)
    sleep(2)
    empty_directory(aruba_dir)
  end

  log("Left in ./tmp/aruba: #{Dir.entries(aruba_dir).join(' ')}") unless Dir.empty?(aruba_dir)
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
