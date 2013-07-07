require 'spec_helper'
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe Connection do
      class TestConnection < Connection
        attr_accessor :socket
      end

      class TestConfiguration
        attr_reader :custom_timeout

        def initialize
          @custom_timeout = {}
        end

        def timeout(message = nil)
          return :default_timeout if message.nil?
          @custom_timeout[message] || Configuration::DEFAULT_TIMEOUTS.fetch(message)
        end

        def host
          'localhost'
        end

        def port
          '3902'
        end
      end

      before(:each) do
        @config = TestConfiguration.new
        @connection = TestConnection.new(@config)
        @connection.socket = @socket = double('socket').as_null_object
        @response = %q{["response"]}
      end

      it "re-raises a timeout error" do
        Timeout.stub(:timeout).and_raise(Timeout::Error.new(''))
        lambda { @connection.call_remote(nil, :foo, []) }.should raise_error(Timeout::Error)
      end

      it "ignores timeout errors when configured to do so" do
        @config.custom_timeout[:foo] = :never
        @socket.stub(:gets => @response)
        handler = double(:handle_response => :response)
        @connection.call_remote(handler, :foo, []).should == :response
      end

      it "raises an exception on remote connection closed" do
        @config.custom_timeout[:foo] = :never
        @socket.stub(:gets => nil)
        lambda { 
          @connection.call_remote(nil, :foo, []) 
        }.should raise_error(WireException, 'Remote Socket with localhost:3902 closed.')
      end
    end
  end
end
