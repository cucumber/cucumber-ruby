require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Formatters
    describe ProgressFormatter do
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
          :error => Pending.new
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
    end
  end
end
