require 'spec_helper'
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe WireException do
      before(:each) do
        @config = Configuration.new('host' => 'localhost', 'port' => 54321)
      end

      def exception
        WireException.new(@data, @config)
      end

      describe "with just a message" do
        before(:each) do
          @data = {'message' => 'foo'}
        end

        it "#to_s as expecteds" do
          expect(exception.to_s).to eq "foo"
        end
      end

      describe "with a message and an exception" do
        before(:each) do
          @data = {'message' => 'foo', 'exception' => 'Bar'}
        end

        it "#to_s as expecteds" do
          expect(exception.to_s).to eq "foo"
        end

        it "#class.to_s returns the name of the exception" do
          expect(exception.class.to_s).to eq 'Bar from localhost:54321'
        end
      end

      describe "with a custom backtrace" do
        before(:each) do
          @data = {'message' => 'foo', 'backtrace' => ['foo', 'bar', 'baz']}
        end

        it "#backrace returns the custom backtrace" do
          expect(exception.backtrace).to eq ['foo', 'bar', 'baz']
        end
      end
    end
  end
end
