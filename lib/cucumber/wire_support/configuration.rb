require 'yaml'
require 'erb'

module Cucumber
  module WireSupport
    class Configuration
      attr_reader :host, :port, :unix

      def initialize(wire_file)
        if Hash === wire_file
          params = wire_file.reduce({}) { |h,(k,v)| h[k.to_s] = v; h }
        else
          params = YAML.load(ERB.new(File.read(wire_file)).result)
        end

        @host = params['host']
        @port = params['port']
        @unix = params['unix'] if RUBY_PLATFORM !~ /mingw|mswin/
        @timeouts = DEFAULT_TIMEOUTS.merge(params['timeout'] || {})
      end

      def timeout(message = nil)
        return @timeouts[message.to_s] || 3
      end

      def to_s
        return @unix if @unix
        "#{@host}:#{@port}"
      end

      DEFAULT_TIMEOUTS = {
        'connect' => 11,
        'invoke' => 120,
        'begin_scenario' => 120,
        'end_scenario' => 120
      }
    end
  end
end
