require 'socket'
require 'json'
require 'logging'

# * better logging
# * snippet text
# * implement wire server in .net
# * Send message to server:
#   2 bytes: len, command, data
# * alias
module Cucumber
  module WireSupport
    
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
        case(result)
        when /^OK/
          return
        when /^DIFF:(.*)/
          other_table = JSON.parse($1)
          table = args[-1] # That's a safe assumption
          begin
            table.diff!(other_table)
            @invoker.call("DIFFOK")
          rescue Ast::Table::Different => e
            result = @invoker.call("DIFFKO")
            if result =~  /^FAIL:(.*)/
              e.backtrace.insert(1, JSON.parse($1)['backtrace'])
              e.backtrace.flatten!
            end
            raise e
          end
        when /^FAIL:(.*)/
          raise WireException.new($1)
        end
      end
      
      private
      
      def invoke_message(args)
        "invoke:" + { :id => id, :args => args }.to_json
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
        # TODO: call remote end and ask for a formatted snippet
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

require 'cucumber/wire_support/wire_exception'

Logging::Logger[Cucumber::WireSupport].add_appenders(
  Logging::Appenders::File.new('/cucumber.log')
)
Logging::Logger[Cucumber::WireSupport].level = :debug
