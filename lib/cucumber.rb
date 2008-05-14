$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'rubygems'
require 'treetop'
require 'cucumber/version'
require 'cucumber/cli'
require 'cucumber/executor'
require 'cucumber/stories'
require 'cucumber/progress_formatter'
require 'cucumber/visitors/html_formatter'
require 'cucumber/parser/story_parser'

module Cucumber
  
end