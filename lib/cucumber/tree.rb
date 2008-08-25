%w{features feature scenario step given_scenario table top_down_visitor}.each{|f| require "cucumber/tree/#{f}"}
require 'cucumber/core_ext/proc'
require 'cucumber/core_ext/string'

module Cucumber
  module Tree
    def Feature(header, &proc)
      feature = Feature.new("Feature: " + header, &proc)
      feature.file, _, _ = *caller[0].split(':')
      features << feature
      feature
    end

    def features #:nodoc:
      @features ||= Tree::Features.new
    end
  end
end