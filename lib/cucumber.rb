$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'rubygems'
require 'treetop/runtime'
require 'treetop/ruby_extensions'
require 'cucumber/version'
require 'cucumber/cli'
require 'cucumber/executor'
require 'cucumber/formatters'
require 'cucumber/parser/story_parser'

module Cucumber
  
end