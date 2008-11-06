require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber::Formatters
  describe AutotestFormatter do
    before(:each) do
      @io        = StringIO.new
      @formatter = AutotestFormatter.new @io
      @scenario  = mock('scenario', :name => "Doing tricky things")
      @step      = mock('step', :scenario => @scenario)
    end

    %w{failed skipped pending}.each do |didnt_pass|
      it "should print a scenario's name when it has a #{didnt_pass} step" do
        @formatter.send("step_#{didnt_pass}".to_sym, @step, mock('regexp'), mock('args'))
        @io.string.should == "Doing tricky things\n"
      end
    end

    it "should not print the same scenario's name twice" do
      another_step = mock('another step', :scenario => @scenario)
      @formatter.send("step_failed".to_sym, @step,         mock('regexp'), mock('args'))
      @formatter.send("step_skipped".to_sym, another_step, mock('regexp'), mock('args'))
      @io.string.should == "Doing tricky things\n"
    end
  end
end