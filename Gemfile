gem "cucumber-pro", "0.0.13", :group => :test
source "https://rubygems.org"
gemspec
unless ENV['CUCUMBER_USE_RELEASED_CORE']
  core_path = File.expand_path("../../cucumber-ruby-core", __FILE__)
  if File.exist?(core_path) && !ENV['CUCUMBER_USE_GIT_CORE']
    gem 'cucumber-core', :path => core_path
  else
    gem 'cucumber-core', :git => "git://github.com/cucumber/cucumber-ruby-core.git"
  end
  gem 'gherkin3', github: "cucumber/gherkin3", branch: "integrate-ruby-core"
end
