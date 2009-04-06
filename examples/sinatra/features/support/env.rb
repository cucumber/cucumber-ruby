# See http://wiki.github.com/aslakhellesoy/cucumber/sinatra
# for more details about Sinatra with Cucumber

# Sinatra
app_file = File.join(File.dirname(__FILE__), *%w[.. .. app.rb])
require app_file
# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = app_file

# RSpec
require 'spec/expectations'

# Webrat
require 'webrat'
Webrat.configure do |config|
  config.mode = :sinatra
end

World{Webrat::SinatraSession.new}
World(Webrat::Matchers, Webrat::HaveTagMatcher)
