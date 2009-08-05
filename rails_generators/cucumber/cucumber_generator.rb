require 'rbconfig'
require 'cucumber/version'

# This generator bootstraps a Rails project for use with Cucumber
class CucumberGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  attr_accessor :framework

  def manifest
    record do |m|
      m.directory 'features/step_definitions'
      m.template  'webrat_steps.rb', 'features/step_definitions/webrat_steps.rb'
      m.template  'cucumber_environment.rb', 'config/environments/cucumber.rb',
        :assigns => { :cucumber_version => ::Cucumber::VERSION::STRING }

      m.gsub_file 'config/database.yml', /test:.*\n/, "test: &TEST\n"
      m.gsub_file 'config/database.yml', /\z/, "\ncucumber:\n  <<: *TEST"

      m.directory 'features/support'

      if spork?
        m.template  'spork_env.rb',     'features/support/env.rb'
      else
        m.template  'env.rb',           'features/support/env.rb'
      end

      m.file      'paths.rb',         'features/support/paths.rb'

      m.directory 'lib/tasks'
      m.template  'cucumber.rake',    'lib/tasks/cucumber.rake'

      m.file      'cucumber',         'script/cucumber', {
        :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang]
      }
    end
  end

  def framework
    options[:framework] || :rspec
  end
  
  def spork?
    options[:spork]
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

    opt.on('--spork', 'Setup cucumber for use with Spork') do |value|
      options[:spork] = true
    end
  end

end
