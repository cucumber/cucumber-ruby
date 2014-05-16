# encoding: utf-8
require 'spec_helper'
require 'cucumber/core_ext/proc'

describe Proc do
  it "removes extraneous path info for file" do
    proc = lambda {|a,b|}

    expect(proc.file_colon_line).to match /^spec\/cucumber\/core_ext\/proc_spec\.rb:7/
  end

  it "works with non-English path" do
    proc = lambda {|a,b|}
    def proc.to_s
      "#<Proc:0x00000003c04740@#{Dir.pwd}/å/spec/cucumber/core_ext/proc_spec.rb:12 (lambda)>".force_encoding('ASCII-8BIT')
    end

    expect(proc.file_colon_line.force_encoding('UTF-8')).to match /^å\/spec\/cucumber\/core_ext\/proc_spec\.rb:12/
  end

  it "raises ArityMismatchError for too many args (expecting 0)" do
    expect(-> {
      Object.new.cucumber_instance_exec(true, 'foo', 1) do
      end
    }).to raise_error(Cucumber::ArityMismatchError, "Your block takes 0 arguments, but the Regexp matched 1 argument.")
  end

  it "raises ArityMismatchError for too many args (expecting 1)" do
    expect(-> {
      Object.new.cucumber_instance_exec(true, 'foo', 1,2) do |a|
      end
    }).to raise_error(Cucumber::ArityMismatchError, "Your block takes 1 argument, but the Regexp matched 2 arguments.")
  end

  it "raises ArityMismatchError for too few args (expecting 1)" do
    expect(-> {
      Object.new.cucumber_instance_exec(true, 'foo') do |a|
      end
    }).to raise_error(Cucumber::ArityMismatchError, "Your block takes 1 argument, but the Regexp matched 0 arguments.")
  end

  it "raises ArityMismatchError for too few args (expecting 2)" do
    expect(-> {
      Object.new.cucumber_instance_exec(true, 'foo', 1) do |a,b|
      end
    }).to raise_error(Cucumber::ArityMismatchError, "Your block takes 2 arguments, but the Regexp matched 1 argument.")
  end

  it "allows varargs (expecting 0+)" do
    expect(-> {
      Object.new.cucumber_instance_exec(true, 'foo', 1) do |*args|
      end
    }).not_to raise_error
  end

  it "allows varargs (expecting 1+)" do
    expect(-> {
      Object.new.cucumber_instance_exec(true, 'foo', 1) do |arg,*args|
      end
    }).not_to raise_error
  end

  it "raises ArityMismatchError for too few required args when using varargs (expecting 1+)" do
    expect(-> {
      Object.new.cucumber_instance_exec(true, nil) do |arg,*args|
      end
    }).to raise_error(Cucumber::ArityMismatchError, "Your block takes 1+ arguments, but the Regexp matched 0 arguments.")
  end
end
