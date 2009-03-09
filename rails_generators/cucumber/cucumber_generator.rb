require 'rbconfig'

# This generator bootstraps a Rails project for use with Cucumber
class CucumberGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  attr_accessor :framework

  def manifest
    record do |m|
      m.directory 'features/step_definitions'
      m.template  'webrat_steps.rb', 'features/step_definitions/webrat_steps.rb'

      m.directory 'features/support'
      m.template  'env.rb',           'features/support/env.rb'
      m.file      'paths.rb',         'features/support/paths.rb'

      m.directory 'lib/tasks'
      m.file      'cucumber.rake',    'lib/tasks/cucumber.rake'

      m.file      'cucumber',         'script/cucumber', {
        :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang]
      }
    end
  end

  def framework
    options[:framework] || :rspec
  end

protected

  def banner
    "Usage: #{$0} cucumber"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on('--rspec', 'Setup cucumber for use with RSpec (default)') do |value|
      options[:framework] = :rspec
    end

    opt.on('--testunit', 'Setup cucumber for use with test/unit') do |value|
      options[:framework] = :testunit
    end
  end

end
