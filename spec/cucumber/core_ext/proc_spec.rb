require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module CoreExt
    describe "proc extended with CallIn" do
      it "should raise ArityMismatchError for too many args (expecting 0)" do
        proc = lambda {}
        proc.extend CallIn
        lambda {
          proc.call_in(Object.new, 1)
        }.should raise_error(Cucumber::ArityMismatchError, "expected 0 block argument(s), got 1")
      end

      it "should raise ArityMismatchError for too many args (expecting 1)" do
        proc = lambda {|a|}
        proc.extend CallIn
        lambda {
          proc.call_in(Object.new, 1, 2)
        }.should raise_error(Cucumber::ArityMismatchError, "expected 1 block argument(s), got 2")
      end

      it "should raise ArityMismatchError for too few args (expecting 1)" do
        proc = lambda {|a|}
        proc.extend CallIn
        lambda {
          proc.call_in(Object.new)
        }.should raise_error(Cucumber::ArityMismatchError, "expected 1 block argument(s), got 0")
      end

      it "should raise ArityMismatchError for too few args (expecting 2)" do
        proc = lambda {|a,b|}
        proc.extend CallIn
        lambda {
          proc.call_in(Object.new, 1)
        }.should raise_error(Cucumber::ArityMismatchError, "expected 2 block argument(s), got 1")
      end
      
      it "should remove extraneous path info for file" do
        proc = lambda {|a,b|}
        proc.extend CallIn
        proc.file_colon_line.should == "spec/cucumber/core_ext/proc_spec.rb:39"
      end
    end
  end
end