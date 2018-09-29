source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

if ENV['CUCUMBER_RUBY_CORE']
  gem 'cucumber-core', path: ENV['CUCUMBER_RUBY_CORE']
elsif !ENV['CUCUMBER_USE_RELEASED_GEMS']
  gem 'cucumber-core', github: 'cucumber/cucumber-ruby-core'
end

if ENV['CUCUMBER_RUBY_WIRE']
  gem 'cucumber-wire', path: ENV['CUCUMBER_RUBY_WIRE']
elsif !ENV['CUCUMBER_USE_RELEASED_GEMS']
  gem 'cucumber-wire', github: 'cucumber/cucumber-ruby-wire'
end

gem 'cucumber-expressions', path: ENV['CUCUMBER_EXPRESSIONS_RUBY'] if ENV['CUCUMBER_EXPRESSIONS_RUBY']

gem 'gherkin', path: ENV['GHERKIN_RUBY'] if ENV['GHERKIN_RUBY']

gem 'cucumber-messages', path: ENV['CUCUMBER_MESSAGES_RUBY'] if ENV['CUCUMBER_MESSAGES_RUBY']

gem 'cucumber-formatter-dots', path: ENV['CUCUMBER_FORMATTER_DOTS'] if ENV['CUCUMBER_FORMATTER_DOTS']
