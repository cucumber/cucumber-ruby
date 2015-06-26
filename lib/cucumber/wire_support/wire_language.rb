require 'multi_json'
require 'socket'
require 'cucumber/wire_support/connection'
require 'cucumber/wire_support/configuration'
require 'cucumber/wire_support/wire_packet'
require 'cucumber/wire_support/wire_exception'
require 'cucumber/wire_support/wire_step_definition'
require 'cucumber/wire_support/snippet'
require 'cucumber/configuration'

module Cucumber
  module WireSupport

    # The wire-protocol (language independent) implementation of the programming
    # language API.
    class WireLanguage

      def initialize(_=nil, configuration = Cucumber::Configuration.new)
        @connections = []
        configuration.snippet_generators << Snippet::Generator.new(@connections)
      end

      def load_code_file(wire_file)
        config = Configuration.from_file(wire_file)
        @connections << Connection.new(config)
      end

      def step_matches(step_name, formatted_step_name)
        @connections.map{ |c| c.step_matches(step_name, formatted_step_name)}.flatten
      end

      def begin_scenario(scenario)
        @connections.each { |c| c.begin_scenario(scenario) }
        @current_scenario = scenario
      end

      def end_scenario
        scenario = @current_scenario
        @connections.each { |c| c.end_scenario(scenario) }
        @current_scenario = nil
      end

      def after_configuration(configuration)
        hooks[:after_configuration].each do |hook|
          hook.invoke('AfterConfiguration', configuration)
        end
      end

      def execute_transforms(args)
        args.map do |arg|
          matching_transform = transforms.detect {|transform| transform.match(arg) }
          matching_transform ? matching_transform.invoke(arg) : arg
        end
      end

      def add_hook(phase, hook)
        hooks[phase.to_sym] << hook
        hook
      end

      def clear_hooks
        @hooks = nil
      end

      def add_transform(transform)
        transforms.unshift transform
        transform
      end

      def hooks_for(phase, scenario) #:nodoc:
        hooks[phase.to_sym].select{|hook| scenario.accept_hook?(hook)}
      end

      def unmatched_step_definitions
        available_step_definition_hash.keys - invoked_step_definition_hash.keys
      end

      def available_step_definition(regexp_source, file_colon_line)
        available_step_definition_hash[StepDefinitionLight.new(regexp_source, file_colon_line)] = nil
      end

      def invoked_step_definition(regexp_source, file_colon_line)
        invoked_step_definition_hash[StepDefinitionLight.new(regexp_source, file_colon_line)] = nil
      end

      private

      def available_step_definition_hash
        @available_step_definition_hash ||= {}
      end

      def invoked_step_definition_hash
        @invoked_step_definition_hash ||= {}
      end

      def hooks
        @hooks ||= Hash.new{|h,k| h[k] = []}
      end

      def transforms
        @transforms ||= []
      end

    end
  end
end
