require File.dirname(__FILE__) + '/../spec_helper'

module Cucumber
  describe Broadcaster do
    
    it "should broadcast methods to registered objects" do
      broadcaster = Broadcaster.new
      mock_receiver = mock('receiver')
      
      mock_receiver.should_receive(:konbanwa).with('good evening')
      broadcaster.register(mock_receiver)
      
      broadcaster.konbanwa('good evening')
    end
  end
end
