require 'spec_helper'
require 'cucumber/formatter/ansicolor'

module Cucumber
  module Formatter
    describe ANSIColor do
      include ANSIColor

      it "should wrap passed_param with bold green and reset to green" do
        passed_param("foo").should == "\e[32m\e[1mfoo\e[0m\e[0m\e[32m"
      end

      it "should wrap passed in green" do
        passed("foo").should == "\e[32mfoo\e[0m"
      end

      it "should not reset passed if there are no arguments" do
        passed.should == "\e[32m"
      end

      it "should wrap comments in grey" do
        comment("foo").should == "\e[90mfoo\e[0m"
      end

      it "should not generate ansi codes when colors are disabled" do
        ::Cucumber::Term::ANSIColor.coloring = false
        passed("foo").should == "foo"
      end
    end

    describe ANSIColor, 'uncolored' do
      include ANSIColor

      it "should uncolor bold greem and reset" do
        uncolored("\e[32m\e[1mfoo\e[0m\e[0m\e[32m").should == 'foo'
      end

      it "should uncolor wrapped in green" do
        uncolored("\e[32mfoo\e[0m").should == 'foo'
      end

      it "should uncolor separate foreground color" do
        uncolored("\e[0;33mfoo").should == 'foo'
      end
    end
  end
end
