$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'cucumber/version'
require 'cucumber/step_mother'
require 'cucumber/runner'
require 'cucumber/visitor'
require 'cucumber/step_verifier'

module Cucumber
  
end