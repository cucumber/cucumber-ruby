require File.dirname(__FILE__) + '/../../spec_helper'


module Cucumber
  module Cli
    describe DRbClient do
      before(:each) do
        @args = ['features']
        @error_stream = StringIO.new
        @out_stream = StringIO.new

        @drb_object = mock('DRbObject', :run => true)
        DRbObject.stub!(:new_with_uri).and_return(@drb_object)
      end

      it "starts up a druby service" do
        DRb.should_receive(:start_service).with("druby://localhost:0")
        DRbClient.run(@args, @error_stream, @out_stream)
      end

      it "connects to the DRb server" do
        DRbObject.should_receive(:new_with_uri).with("druby://127.0.0.1:8990")
        DRbClient.run(@args, @error_stream, @out_stream)
      end

      it "runs the fearures on the DRb server" do
        @drb_object.should_receive(:run).with(@args, @error_stream, @out_stream)
        DRbClient.run(@args, @error_stream, @out_stream)
      end

      it "returns false when it can't connect to the server" do
        DRbObject.stub!(:new_with_uri).and_raise(DRb::DRbConnError)
        DRbClient.run(@args, @error_stream, @out_stream).should be_false
      end

      it "returns true when it connects to the server and runs the features" do
        DRbClient.run(@args, @error_stream, @out_stream).should be_true
      end

    end
  end
end
