require 'rbconfig'

# This generator bootstraps a Rails project for use with Cucumber
class CucumberGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])
  def manifest
    record do |m|
      m.directory 'features/step_definitions'
      m.file      'webrat_steps.rb', 'features/step_definitions/webrat_steps.rb'

      m.directory 'features/support'
      m.file      'env.rb',           'features/support/env.rb'

      m.directory 'lib/tasks'
      m.file      'cucumber.rake',    'lib/tasks/cucumber.rake'

      m.file      'cucumber',         'script/cucumber', {
        :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang]
      }
    end
  end

protected

  def banner
    "Usage: #{$0} cucumber"
  end

end