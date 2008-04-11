require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/../spec/spec_helper'
require 'stories/steps/stories_steps'

runner = Stories::Runner.new
runner
with_steps_for :stories do
  run 'stories/sell_stories.story'
end
