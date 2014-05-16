require 'spec_helper'
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe WirePacket do
      describe "#to_json" do
        it "converts params to a JSON hash" do
          packet = WirePacket.new('test_message', :foo => :bar)

          expect(packet.to_json).to eq "[\"test_message\",{\"foo\":\"bar\"}]"
        end

        it "does not pass blank params" do
          packet = WirePacket.new('test_message')

          expect(packet.to_json).to eq "[\"test_message\"]"
        end
      end

      describe ".parse" do
        it "understands a raw packet containing null parameters" do
          packet = WirePacket.parse("[\"test_message\",null]")

          expect(packet.message).to eq 'test_message'
          expect(packet.params).to be_nil
        end

        it "understands a raw packet containing no parameters" do
          packet = WirePacket.parse("[\"test_message\"]")

          expect(packet.message).to eq 'test_message'
          expect(packet.params).to be_nil
        end

        it "understands a raw packet containging parameters data" do
          packet = WirePacket.parse("[\"test_message\",{\"foo\":\"bar\"}]")

          expect(packet.params['foo']).to eq 'bar'
        end
      end
    end
  end
end
