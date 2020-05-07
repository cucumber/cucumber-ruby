source 'https://rubygems.org'
gemspec

if ENV['CUCUMBER_RUBY_CORE']
  gem 'cucumber-core', :path => ENV['CUCUMBER_RUBY_CORE']
end

if ENV['CUCUMBER_RUBY_WIRE']
  gem 'cucumber-wire', :path => ENV['CUCUMBER_RUBY_WIRE']
end

if ENV['CUCUMBER_EXPRESSIONS_RUBY']
  gem 'cucumber-expressions', :path => ENV['CUCUMBER_EXPRESSIONS_RUBY']
end

group :development do
  gem 'webrick', '~> 1.6', '>= 1.6.0' unless RUBY_VERSION < '2.3'
end
