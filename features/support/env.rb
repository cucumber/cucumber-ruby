ENV['FORCE_COLOR'] = 'true'

require 'aruba'
require 'aruba/api'
require 'aruba/cucumber'
require 'aruba/in_process'
require 'aruba/spawn_process'
require 'cucumber/rspec/disable_option_parser'
require 'cucumber/cli/main'

# Monkey patch aruba to filter out some stuff
module Aruba::Api
  alias __all_stdout all_stdout

  def all_stdout
    unrandom(__all_stdout)
  end

  alias __all_stderr all_stderr
  def all_stderr
    err = __all_stderr
    if Cucumber::JRUBY
      # TODO: this actually a workaround for cucumber/gherkin#238
      err = err.gsub(/^.*java_package_module_template.rb:\d+ warning: `eval' should not be aliased.*\n/, '')
    end
    err
  end

  def unrandom(out)
    out = out.gsub(/#{Dir.pwd}\/tmp\/aruba/, '.') # Remove absolute paths
    out = out.gsub(/tmp\/aruba\//, '')            # Fix aruba path
    out = out.gsub(/^.*cucumber_process\.rb.*$\n/, '')
    out = out.gsub(/^\d+m\d+\.\d+s$/, '0m0.012s') # Make duration predictable
    out = out.gsub(/Coverage report generated for Cucumber Features to #{Dir.pwd}\/coverage.*\n$/, '') # Remove SimpleCov message
  end
end

Before('@spawn') do
  Aruba.process = Aruba::SpawnProcess
end

Before('~@spawn') do
  Aruba::InProcess.main_class = Cucumber::Cli::Main
  Aruba.process = Aruba::InProcess
end

Before do
  # Make sure bin/cucumber runs with SimpleCov enabled
  # set_env('SIMPLECOV', 'true')

  # Set a longer timeout for aruba, and a really long one if running on JRuby
  @aruba_timeout_seconds = Cucumber::JRUBY ? 35 : 15
end

After do
  terminate_background_jobs
end
