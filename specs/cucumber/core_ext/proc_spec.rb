require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/core_ext/instance_exec'

describe Proc do
  it "should raise ArityMismatchError for too many args (expecting 0)" do
    lambda {
      Object.new.cucumber_instance_exec(true, 'foo', 1) do
      end
    }.should raise_error(Cucumber::ArityMismatchError, "expected 0 block argument(s), got 1")
  end

  it "should raise ArityMismatchError for too many args (expecting 1)" do
    lambda {
      Object.new.cucumber_instance_exec(true, 'foo', 1,2) do |a|
      end
    }.should raise_error(Cucumber::ArityMismatchError, "expected 1 block argument(s), got 2")
  end

  it "should raise ArityMismatchError for too few args (expecting 1)" do
    lambda {
      Object.new.cucumber_instance_exec(true, 'foo') do |a|
      end
    }.should raise_error(Cucumber::ArityMismatchError, "expected 1 block argument(s), got 0")
  end

  it "should raise ArityMismatchError for too few args (expecting 2)" do
    lambda {
      Object.new.cucumber_instance_exec(true, 'foo', 1) do |a,b|
      end
    }.should raise_error(Cucumber::ArityMismatchError, "expected 2 block argument(s), got 1")
  end
  
  it "should remove extraneous path info for file" do
    proc = lambda {|a,b|}
    proc.file_colon_line.should == "specs/cucumber/core_ext/proc_spec.rb:34"
  end
end
