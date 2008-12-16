require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Formatters
    describe ProgressFormatter do
      before do
        ::Term::ANSIColor.coloring = false
      end

      after do
        ::Term::ANSIColor.coloring = true
      end
      
      it "should print . when passed" do
        io = StringIO.new
        formatter = ProgressFormatter.new io
        step = stub('step',
          :error => nil
        )
        formatter.step_passed(step,nil,nil)
        io.string.should =~ /^\.$/
      end

      it "should print F when failed" do
        io = StringIO.new
        formatter = ProgressFormatter.new io
        step = stub('step',
          :error => StandardError.new
        )
        formatter.step_failed(step,nil,nil)
        io.string.should =~ /^\F$/
      end

      it "should print P when pending" do
        io = StringIO.new
        formatter = ProgressFormatter.new io
        step = stub('step',
          :error => Pending.new,
          :scenario => mock('scenario')
        )
        formatter.step_pending(step,nil,nil)
        io.string.should =~ /^\P$/
      end

      it "should print _ when skipped" do
        io = StringIO.new
        formatter = ProgressFormatter.new io
        formatter.step_skipped(nil,nil,nil)
        io.string.should =~ /^_$/
      end

      it "should print nothing when traced" do
        io = StringIO.new
        formatter = ProgressFormatter.new io
        formatter.step_traced(nil, nil, nil)
        
        io.string.should =~ /^$/
      end

      describe "scenario without any steps" do
        before :each do
          @io         = StringIO.new
          @formatter  = ProgressFormatter.new(@io)
          @feature    = stub("feature", :header => "Feature Header")
          @scenario   = stub("scenario", :feature => @feature, :name => "Scenario Title", :row? => false, :pending? => true)
        end

        it "should print a P when executing" do
          @formatter.should_receive(:pending).with("P")
          @formatter.scenario_executing(@scenario)
        end

        it "should display as pending in the dump" do
          @formatter.scenario_executing(@scenario)
          @formatter.dump
          @io.string.should include("Feature Header (Scenario Title)")
        end
      end
    end
  end
end
