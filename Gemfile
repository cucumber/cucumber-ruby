source 'https://rubygems.org'
gemspec

if ENV['CUCUMBER_RUBY_WIRE']
  gem 'cucumber-core', :path => ENV['CUCUMBER_RUBY_WIRE']
else
  gem 'cucumber-core', :git => 'https://github.com/cucumber/cucumber-ruby-core.git'
end

if ENV['CUCUMBER_RUBY_WIRE']
  gem 'cucumber-wire', :path => ENV['CUCUMBER_RUBY_WIRE']
else
  gem 'cucumber-wire', :git => 'https://github.com/cucumber/cucumber-ruby-wire.git'
end

if ENV['CUCUMBER_EXPRESSIONS_RUBY']
  gem 'cucumber-expressions', :path => ENV['CUCUMBER_EXPRESSIONS_RUBY']
else
  gem 'cucumber-expressions', :git => 'https://github.com/cucumber/cucumber-expressions-ruby.git'
end
