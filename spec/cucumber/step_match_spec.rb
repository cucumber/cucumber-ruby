require File.dirname(__FILE__) + '/../spec_helper'
require 'cucumber/rb_support/rb_step_definition'
require 'cucumber/rb_support/rb_language'

module Cucumber
  describe StepMatch do
    before do
      @rb_language = RbSupport::RbLanguage.new(nil)
    end

    def stepdef(regexp)
      RbSupport::RbStepDefinition.new(@rb_language, regexp, lambda{})
    end

    it "should format groups with format string" do
      m = stepdef(/I (\w+) (\d+) (\w+) this (\w+)/).step_match("I ate 1 egg this morning", nil)
      m.format_args("<span>%s</span>").should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
    end

    it "should format groups with format string when there are dupes" do
      m = stepdef(/I (\w+) (\d+) (\w+) this (\w+)/).step_match("I bob 1 bo this bobs", nil)
      m.format_args("<span>%s</span>").should == "I <span>bob</span> <span>1</span> <span>bo</span> this <span>bobs</span>"
    end

    it "should format groups with block" do
      m = stepdef(/I (\w+) (\d+) (\w+) this (\w+)/).step_match("I ate 1 egg this morning", nil)
      m.format_args(&lambda{|m| "<span>#{m}</span>"}).should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
    end

    it "should format groups with proc object" do
      m = stepdef(/I (\w+) (\d+) (\w+) this (\w+)/).step_match("I ate 1 egg this morning", nil)
      m.format_args(lambda{|m| "<span>#{m}</span>"}).should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
    end

    it "should format groups even when first group is optional and not matched" do
      m = stepdef(/should( not)? be flashed '([^']*?)'$/).step_match("I should be flashed 'Login failed.'", nil)
      m.format_args("<span>%s</span>").should == "I should be flashed '<span>Login failed.</span>'"
    end
  end
end