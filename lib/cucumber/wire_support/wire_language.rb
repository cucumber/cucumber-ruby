require 'socket'
require 'json'

module Cucumber
  module WireSupport
    
    class WireStepDefinition
      include LanguageSupport::StepDefinitionMethods

      def initialize(wire_language, json_data)
        @wire_language, @json_data = wire_language, json_data
      end
      
      def regexp
        Regexp.new @json_data['regexp']
      end

      def id
        @json_data['id']
      end
      
      def invoke(args)
        @wire_language.invoke_wire_step_definition(id, args)
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
        raise "only one .wire at a time please" if @sock
        config = YAML.load_file(wire_file)
        @sock = TCPSocket.new(config['host'], config['port'])
        @sock.puts 'list_step_definitions'
        response = @sock.gets
        JSON.parse(response).map{|step_def_data| WireStepDefinition.new(self, step_def_data)}
      end

      def snippet_text(step_keyword, step_name, multiline_arg_class = nil)
      end

      def invoke_wire_step_definition(step_def_id, args)
        @sock.puts "invoke:" + { :id => step_def_id, :args => args }.to_json
        result = @sock.gets.strip
        raise "EPIC FAIL" unless result == "OK"
        # raise if failed
      end

      protected

      def begin_scenario
      end

      def end_scenario
      end
    end
  end
end