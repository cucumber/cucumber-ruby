%w{features feature scenario step table top_down_visitor}.each{|f| require "cucumber/tree/#{f}"}
require 'cucumber/core_ext/proc'
require 'cucumber/core_ext/string'

module Cucumber
  module Tree
    def Feature(header, &proc)
      features << Feature.new("Feature: " + header, &proc)
    end

    def features #:nodoc:
      @features ||= Tree::Features.new
    end
  end
end