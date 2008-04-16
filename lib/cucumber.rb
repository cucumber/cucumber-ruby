$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'cucumber/version'
require 'cucumber/runner'
require 'cucumber/story_parser'
require 'cucumber/step_mother'
#require 'cucumber/visitor'
#require 'cucumber/visitors'
#require 'cucumber/step_verifier'

module Cucumber
  
end