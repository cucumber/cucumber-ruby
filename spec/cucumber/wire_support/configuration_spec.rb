require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/wire_support/wire_language'
require 'tempfile'

module Cucumber
  module WireSupport
    describe Configuration do
      it "should read the hostname / port from the file" do
        wire_file = Tempfile.new('wire')
        wire_file << %q{
          host: localhost
          port: 54321
        }
        wire_file.close
        config = Configuration.new(wire_file.path)
        config.host.should == 'localhost'
        config.port.should == 54321
      end
      
      it "should read the timeout for a specific message" do
        wire_file = Tempfile.new('wire')
        wire_file << %q{
          host: localhost
          port: 54321
          timeout:
            invoke: 99
        }
        wire_file.close
        config = Configuration.new(wire_file.path)
        config.timeout(:invoke).should == 99
      end
    end
  end
end