source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

def monorepo(name)
  return {} if ENV['CUCUMBER_RELEASED_GEMS']
  path = "../../cucumber/#{name}/ruby"
  if File.directory?(path)
    { path: File.expand_path(path) }
  else
    { git: 'https://github.com/cucumber/cucumber.git', glob: "#{name}/ruby/cucumber-#{name}.gemspec" }
  end
end

def sibling(name)
  return {} if ENV['CUCUMBER_RELEASED_GEMS']
  path = "../#{name}"
  if File.directory?(path)
    { path: File.expand_path(path) }
  else
    # Sibling dependencies must use the same branch
    branch = ENV['CIRCLE_BRANCH']
    { git: "https://github.com/cucumber/#{name}.git", branch: branch }
  end
end

gem 'cucumber-core', sibling('cucumber-ruby-core')
gem 'cucumber-create-meta', monorepo('create-meta')
gem 'cucumber-cucumber-expressions', monorepo('cucumber-expressions')
gem 'cucumber-gherkin', monorepo('gherkin')
# Uncomment the next gem line to use the latest from local filesystem or git.
# It will fail if it isn't built (the assets folder must have the js/css/mustache.html files)
# gem 'cucumber-html-formatter', monorepo('html-formatter')
gem 'cucumber-messages', monorepo('messages')
gem 'cucumber-tag-expressions', monorepo('tag-expressions')
gem 'cucumber-wire', sibling('cucumber-ruby-wire')

require 'rbconfig'
# rubocop:disable Style/DoubleNegation
is_windows = !!(RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
# rubocop:enable Style/DoubleNegation

install_if -> { !is_windows } do
  gem 'rubocop', '~> 0.89', '= 0.89.1'
  gem 'rubocop-packaging', '~> 0.3', '= 0.5.1'
end
