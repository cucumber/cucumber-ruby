require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/../spec/spec_helper'
require 'cucumber/steps/cucumber_steps'

runner = Cucumber::Runner.new
runner
with_steps_for :cucumber do
  run 'cucumber/sell_cucumber.story'
end
