require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/rb_support/rb_step_definition'

module Cucumber
  module RbSupport
    describe RbGroup do
      it "should format groups with format string" do
        d = RbStepDefinition.new(nil, /I (\w+) (\d+) (\w+) this (\w+)/, lambda{})
        m = d.step_match("I ate 1 egg this morning", nil)
        m.format_args("<span>%s</span>").should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
      end

      it "should format groups with format string when there are dupes" do
        d = RbStepDefinition.new(nil, /I (\w+) (\d+) (\w+) this (\w+)/, lambda{})
        m = d.step_match("I bob 1 bo this bobs", nil)
        m.format_args("<span>%s</span>").should == "I <span>bob</span> <span>1</span> <span>bo</span> this <span>bobs</span>"
      end

      it "should format groups with block" do
        d = RbStepDefinition.new(nil, /I (\w+) (\d+) (\w+) this (\w+)/, lambda{})
        m = d.step_match("I ate 1 egg this morning", nil)
        m.format_args(&lambda{|m| "<span>#{m}</span>"}).should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
      end

      it "should format groups with proc object" do
        d = RbStepDefinition.new(nil, /I (\w+) (\d+) (\w+) this (\w+)/, lambda{})
        m = d.step_match("I ate 1 egg this morning", nil)
        m.format_args(lambda{|m| "<span>#{m}</span>"}).should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
      end
    end
  end
end