source 'https://rubygems.org'
gemspec

if ENV['CUCUMBER_RUBY_CORE']
  gem 'cucumber-core', path: ENV['CUCUMBER_RUBY_CORE']
elsif !ENV['CUCUMBER_USE_RELEASED_GEMS']
  gem 'cucumber-core', git: 'git://github.com/cucumber/cucumber-ruby-core.git'
end

if ENV['CUCUMBER_RUBY_WIRE']
  gem 'cucumber-wire', path: ENV['CUCUMBER_RUBY_WIRE']
elsif !ENV['CUCUMBER_USE_RELEASED_GEMS']
  gem 'cucumber-wire', git: 'git://github.com/cucumber/cucumber-ruby-wire.git'
end

gem 'cucumber-expressions', path: ENV['CUCUMBER_EXPRESSIONS_RUBY'] if ENV['CUCUMBER_EXPRESSIONS_RUBY']
