require 'rubygems'
gem 'rspec'
require 'spec/expectations'

ENV['CUCUMBER_COLORS']=nil
$KCODE='u'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber'
Cucumber.load_language('en')
$:.unshift(File.dirname(__FILE__))

::Term::ANSIColor.coloring = true

# Open up the tree classes a little for easier inspection.
module Cucumber
  module Tree
    class Feature
      attr_reader :header, :scenarios
    end
  end
end