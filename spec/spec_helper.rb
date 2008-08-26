require 'rubygems'
gem 'rspec'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber'
require 'cucumber/treetop_parser/feature_en'

# Prevent CLI's exit hook from running
class Cucumber::CLI
  def self.execute_called?
    true
  end
end

# Open up the tree classes a little for easier inspection.
module Cucumber
  module Tree
    class Feature
      attr_reader :header, :scenarios
    end
  end
end