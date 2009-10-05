require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe WirePacket do
      describe ".parse" do
        it "should understand a raw packet containing no arguments" do
          packet = WirePacket.parse('test_message:{}')
          packet.message.should == 'test_message'
        end
        
        it "should understand a raw packet containging JSON data" do
          packet = WirePacket.parse('test_message:{"foo":"bar"}')
          packet.args['foo'].should == 'bar'
        end
      end
    end
  end
end