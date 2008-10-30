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

    it "should not call methods on registered objects if they dont support the method" do
      broadcaster = Broadcaster.new
      mock_receiver = mock('receiver', :respond_to? => false)

      mock_receiver.should_not_receive(:konbanwa)
      broadcaster.register(mock_receiver)
      
      broadcaster.konbanwa()
    end
    
  end
end
