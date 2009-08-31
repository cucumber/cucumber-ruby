require 'socket'
require 'json'
require 'logging'

# * read up on sockets
# * better logging
# * make it work with JSON on one line
#   * list step defs
#   * invoke step def
#     * return pass
#     * fail result
#       * backtrace
#       * exception message
#   * snippet text
#   * implement wire server in .net
# * Send message to server:
#   2 bytes: len, command, data
# * alias
module Cucumber
  module WireSupport
    
    class WireException < StandardError
      def initialize(json)
        @data = JSON.parse(json)
      end
      
      def message
        @data['message']
      end
      
      def backtrace
        @data['backtrace']
      end
    end

    class WireStepDefinition
      include LanguageSupport::StepDefinitionMethods

      def initialize(wire_language, json_data, invoker)
        @wire_language, @data, @invoker = wire_language, json_data, invoker
        @wire_language.register_wire_step_definition(id, self)
      end
      
      def regexp
        Regexp.new @data['regexp']
      end

      def id
        @data['id']
      end
      
      def invoke(args)
        result = @invoker.call(invoke_message(args)).strip
        raise make_error(result) unless result =~ /^OK/
      end
      
      private
      
      def invoke_message(args)
        "invoke:" + { :id => id, :args => args }.to_json
      end
      
      def make_error(result)
        json = result.match(/^FAIL:(.*)/)[1]
        WireException.new(json)
      end
    end

    class RemoteInvoker
      def initialize(filename)
        @wire_file = filename
      end
      
      def call(message, timeout = 5)
        begin
          log.debug("Calling server with message #{message}")
          s = socket
          Timeout.timeout(timeout) { s.puts(message) }
          log.debug("Message sent")
          response = fetch_data_from_socket(timeout)
          log.debug("Received response: #{response.strip}")
          response
        rescue Timeout::Error
          raise "Timed out calling server with message #{message}"
        end
      end
      
      private
      
      def fetch_data_from_socket(timeout)
        log.debug("Waiting #{timeout} secs for response...")
        Timeout.timeout(timeout) { socket.gets }
      end
      
      def socket
        log.debug("opening socket to #{config.inspect}") unless @socket
        @socket ||= TCPSocket.new(config['host'], config['port'])
      end

      def config
        @config ||= YAML.load_file(@wire_file)
      end

      def log
        Logging::Logger[self]
      end      
    end

    # The wire-protocol lanugage independent implementation of the programming language API.
    class WireLanguage
      include LanguageSupport::LanguageMethods

      def initialize(step_mother)
      end

      def alias_adverbs(adverbs)
      end

      def step_definitions_for(wire_file)
        invoker_proxy = RemoteInvoker.new(wire_file)
        response = invoker_proxy.call('list_step_definitions')
        JSON.parse(response).map do |step_def_data| 
          WireStepDefinition.new(self, step_def_data, invoker_proxy)
        end
      end

      def snippet_text(step_keyword, step_name, multiline_arg_class = nil)
      end

      def register_wire_step_definition(id, step_definition)
        step_definitions[id] = step_definitions
      end

      protected

      def begin_scenario
      end

      def end_scenario
      end
      
      def log
        Logging::Logger[self]
      end      
      
      private
      
      def step_definitions
        @step_definitions ||= {}
      end
    end
  end
end

Logging::Logger[Cucumber::WireSupport].add_appenders(
  Logging::Appenders::File.new('/cucumber.log')
)
Logging::Logger[Cucumber::WireSupport].level = :debug
