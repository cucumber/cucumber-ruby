require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/formatters/ansicolor'

module Cucumber
  module Formatters
    describe ANSIColor do
      include ANSIColor
      
      it "should wrap string in bold green for #passed with string arg" do
        passed("foo").should == "\e[0m\e[1m\e[32mfoo\e[0m\e[0m"
      end

      it "should return bold green without wrapping for #passed without arg" do
        passed.should == "\e[0m\e[1m\e[32m"
      end
      
      it "should not generate ansi codes when colors are disabled" do
        ENV['CUCUMBER_COLORS_DISABLED'] = '1'
        passed("foo").should == "foo"
      end
    end
  end
end
