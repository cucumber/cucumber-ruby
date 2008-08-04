require 'rubygems'
gem 'rspec'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber'
require 'cucumber/parser/story_parser_en'

# Prevent CLI's exit hook from running
class Cucumber::CLI
  def self.execute_called?
    true
  end
end
