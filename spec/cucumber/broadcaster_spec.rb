require File.dirname(__FILE__) + '/../spec_helper'

module Cucumber
  describe Broadcaster do
    
    it "should broadcast methods to registered objects" do
      receiver = mock('receiver')
      broadcaster = Broadcaster.new([receiver])

      receiver.should_receive(:konbanwa).with('good evening')
      broadcaster.konbanwa('good evening')
    end
  end
end
