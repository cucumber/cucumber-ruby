require 'cucumber/ruby_tree/nodes'

module Cucumber
  # Classes in this module implement the pure ruby stories in Cucumber.
  module RubyTree
    def Feature(header, &proc)
      stories << RubyFeature.new("Feature: " + header, &proc)
    end

    def stories #:nodoc:
      @stories ||= Tree::Stories.new
    end
  end
end
