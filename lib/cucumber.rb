$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'rubygems'
require 'treetop/runtime'
require 'treetop/ruby_extensions'
require 'cucumber/version'
require 'cucumber/step_methods'
require 'cucumber/ruby_tree'
require 'cucumber/executor'
require 'cucumber/step_mother'
require 'cucumber/formatters'
require 'cucumber/parser/story_parser'
require 'cucumber/cli'

module Cucumber
  
end