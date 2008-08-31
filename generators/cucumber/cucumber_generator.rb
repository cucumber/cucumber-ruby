# This generator bootstraps a Rails project for use with Cucumber
class CucumberGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory 'features/steps'
      m.file      'env.rb', 'features/steps/env.rb'
      m.file      'common_webrat.rb', 'features/steps/common_webrat.rb'

      m.directory 'lib/tasks'
      m.file      'cucumber.rake', 'lib/tasks/cucumber.rake'
      m.file      'cucumber',      'script/cucumber.rake'
    end
  end

protected

  def banner
    "Usage: #{$0} cucumber"
  end

end