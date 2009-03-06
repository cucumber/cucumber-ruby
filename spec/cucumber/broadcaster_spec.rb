require File.dirname(__FILE__) + '/../spec_helper'

module Cucumber
  describe Broadcaster do
    before(:all) do
      @receiver = mock('receiver')
      @broadcaster = Broadcaster.new([@receiver])
    end
    
    it "should broadcast methods to registered objects" do
      @receiver.should_receive(:konbanwa).with('good evening')
      @broadcaster.konbanwa('good evening')
    end

    it "should keep track of each instance" do
      Broadcaster.instances.last.should == @broadcaster
    end

    it "should announce to all broadcasters any announcement" do
      @receiver.should_receive(:announce).with("this is only a test")
      Broadcaster.announce("this is only a test")
    end
      
  end
end
