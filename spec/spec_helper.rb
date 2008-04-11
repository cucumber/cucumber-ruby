begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber'

module Cucumber
  class Parse
    def initialize(text)
      @text = text
    end

    def matches?(story_parser)
      @story_parser = story_parser
      @story_parser.parse(@text)
    end

    def failure_message
      "expected text to parse, but it didn't: #{@story_parser.failure_reason}"
    end

    def negative_failure_message
      "expected text to not parse, but it did!"
    end
  end
  
  def parse(story)
    Parse.new(story)
  end
end

Spec::Runner.configure do |config|
  config.include Cucumber
end