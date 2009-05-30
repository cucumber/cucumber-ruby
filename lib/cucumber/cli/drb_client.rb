require "drb/drb"
# This code was taken from the RSpec project and slightly modified.

module Cucumber
  module Cli
    # Runs features on a DRB server, originally created with Spork compatibility in mind.
    class DRbClient
      def self.run(args, error_stream, out_stream)
        begin
          # See http://redmine.ruby-lang.org/issues/show/496 as to why we specify localhost:0
          DRb.start_service("druby://localhost:0")
          feature_server = DRbObject.new_with_uri("druby://127.0.0.1:8990")
          feature_server.run(args, error_stream, out_stream)
          true
        rescue DRb::DRbConnError
          false
        end
      end
    end
  end
end
