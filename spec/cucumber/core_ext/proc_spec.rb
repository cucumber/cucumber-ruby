# encoding: utf-8
require 'spec_helper'
require 'cucumber/core_ext/proc'

describe Proc do
  it "should remove extraneous path info for file" do
    proc = lambda {|a,b|}
    proc.file_colon_line.should =~ /^spec\/cucumber\/core_ext\/proc_spec\.rb:7/
  end

  unless Cucumber::RUBY_1_8_7
    it "should work with non-English path" do
      proc = lambda {|a,b|}
      def proc.to_s
        "#<Proc:0x00000003c04740@#{Dir.pwd}/å/spec/cucumber/core_ext/proc_spec.rb:12 (lambda)>".force_encoding('ASCII-8BIT')
      end

      proc.file_colon_line.force_encoding('UTF-8').should =~ /^å\/spec\/cucumber\/core_ext\/proc_spec\.rb:12/
    end
  end

  it "should raise ArityMismatchError for too many args (expecting 0)" do
    lambda {
      Object.new.cucumber_instance_exec(true, 'foo', 1) do
      end
    }.should raise_error(Cucumber::ArityMismatchError, "Your block takes 0 arguments, but the Regexp matched 1 argument.")
  end

  it "should raise ArityMismatchError for too many args (expecting 1)" do
    lambda {
      Object.new.cucumber_instance_exec(true, 'foo', 1,2) do |a|
      end
    }.should raise_error(Cucumber::ArityMismatchError, "Your block takes 1 argument, but the Regexp matched 2 arguments.")
  end

  it "should raise ArityMismatchError for too few args (expecting 1)" do
    lambda {
      Object.new.cucumber_instance_exec(true, 'foo') do |a|
      end
    }.should raise_error(Cucumber::ArityMismatchError, "Your block takes 1 argument, but the Regexp matched 0 arguments.")
  end

  it "should raise ArityMismatchError for too few args (expecting 2)" do
    lambda {
      Object.new.cucumber_instance_exec(true, 'foo', 1) do |a,b|
      end
    }.should raise_error(Cucumber::ArityMismatchError, "Your block takes 2 arguments, but the Regexp matched 1 argument.")
  end

  if Cucumber::RUBY_1_8_7
    # Ruby 1.8
    it "should not allow varargs 0+ because Ruby 1.8 reports same arity as with no args, so we can't really tell the difference." do
      lambda {
        Object.new.cucumber_instance_exec(true, 'foo', 1) do |*args|
        end
      }.should raise_error(Cucumber::ArityMismatchError, "Your block takes 0 arguments, but the Regexp matched 1 argument.")
    end
  else
    it "should allow varargs (expecting 0+)" do
      lambda {
        Object.new.cucumber_instance_exec(true, 'foo', 1) do |*args|
        end
      }.should_not raise_error
    end
  end

  it "should allow varargs (expecting 1+)" do
    lambda {
      Object.new.cucumber_instance_exec(true, 'foo', 1) do |arg,*args|
      end
    }.should_not raise_error
  end

  it "should raise ArityMismatchError for too few required args when using varargs (expecting 1+)" do
    lambda {
      Object.new.cucumber_instance_exec(true, nil) do |arg,*args|
      end
    }.should raise_error(Cucumber::ArityMismatchError, "Your block takes 1+ arguments, but the Regexp matched 0 arguments.")
  end
end
