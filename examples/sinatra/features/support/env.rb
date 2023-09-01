# frozen_string_literal: true

# See http://wiki.github.com/cucumber/cucumber/sinatra
# for more details about Sinatra with Cucumber

require "#{File.dirname(__FILE__)}/../../app"

require 'rack/test'
require 'capybara/cucumber'

Capybara.app = Sinatra::Application
