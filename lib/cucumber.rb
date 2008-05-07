$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'treetop'
require 'cucumber/version'
require 'cucumber/cli'
require 'cucumber/executor'

module Cucumber
  
end