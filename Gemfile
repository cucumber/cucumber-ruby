gem 'cucumber-pro', '0.0.13', group: :test
source 'https://rubygems.org'
gemspec
load File.expand_path('../Gemfile.local', __FILE__) if File.file? File.expand_path('../Gemfile.local', __FILE__)

unless ENV['CUCUMBER_USE_RELEASED_CORE']
  core_path = File.expand_path('../../cucumber-ruby-core', __FILE__)
  wire_path = File.expand_path('../../cucumber-ruby-wire', __FILE__)
  if File.exist?(core_path) && !ENV['cucumber_use_git_core']
    gem 'cucumber-core', path: core_path
  else
    gem 'cucumber-core', git: 'https://github.com/cucumber/cucumber-ruby-core.git'
  end

  if File.exist?(wire_path) && !ENV['CUCUMBER_USE_GIT_CORE']
    gem 'cucumber-wire', path: wire_path
  else
    gem 'cucumber-wire', git: 'https://github.com/cucumber/cucumber-ruby-wire.git'
  end
end

gem 'mime-types', '~>2.99'
