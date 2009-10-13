require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe WirePacket do
      it "should convert to JSON" do
        packet = WirePacket.new('test_message', :foo => :bar)
        packet.to_json.should == "{\"message\":\"test_message\",\"params\":{\"foo\":\"bar\"}}"
      end
      
      describe ".parse" do
        it "should understand a raw packet containing no arguments" do
          packet = WirePacket.parse("{\"message\":\"test_message\",\"params\":null}")
          packet.message.should == 'test_message'
          packet.params.should be_nil
        end
        
        it "should understand a raw packet containging arguments data" do
          packet = WirePacket.parse("{\"message\":\"test_message\",\"params\":{\"foo\":\"bar\"}}")
          packet.params['foo'].should == 'bar'
        end
        
        it "should raise an error if either mandatory key is missing" do
          lambda{ WirePacket.parse("{\"message\":\"test\"}") }.should raise_error(WirePacket::ParseError)
        end
      end
    end
  end
end