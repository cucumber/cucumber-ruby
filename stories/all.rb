require 'rubygems'
require 'spec/story'
require File.dirname(__FILE__) + '/../spec/spec_helper'
require 'stories/steps/stories_steps'

with_steps_for :stories do
  run 'stories/sell_stories.story'
end
