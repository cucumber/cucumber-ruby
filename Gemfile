source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

if ENV['CUCUMBER_RUBY_CORE']
  gem 'cucumber-core', path: ENV['CUCUMBER_RUBY_CORE']
elsif !ENV['CUCUMBER_USE_RELEASED_GEMS']
  gem 'cucumber-core', github: 'cucumber/cucumber-ruby-core', branch: 'main'
end

if ENV['CUCUMBER_RUBY_WIRE']
  gem 'cucumber-wire', path: ENV['CUCUMBER_RUBY_WIRE']
elsif !ENV['CUCUMBER_USE_RELEASED_GEMS']
  gem 'cucumber-wire', github: 'cucumber/cucumber-ruby-wire', branch: 'main'
end

gem 'cucumber-expressions', path: ENV['CUCUMBER_EXPRESSIONS_RUBY'] if ENV['CUCUMBER_EXPRESSIONS_RUBY']
gem 'cucumber-gherkin', path: ENV['GHERKIN_RUBY'] if ENV['GHERKIN_RUBY']
gem 'cucumber-html-formatter', path: ENV['CUCUMBER_HTML_FORMATTER_RUBY'] if ENV['CUCUMBER_HTML_FORMATTER_RUBY']
gem 'cucumber-messages', path: ENV['CUCUMBER_MESSAGES_RUBY'] if ENV['CUCUMBER_MESSAGES_RUBY']

gem 'rubocop', '~> 1.10', '= 1.10.0'
gem 'rubocop-packaging', '~> 0.3', '= 0.5.1'
