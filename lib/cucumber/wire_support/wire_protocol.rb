require 'cucumber/step_argument'
require 'cucumber/wire_support/request_handler'

module Cucumber
  module WireSupport
    module WireProtocol
      module Requests
        class StepMatches < RequestHandler
          def initialize(connection)
            @connection = connection
            super(connection, :step_matches)
          end
          
          def execute(params)
            @name_to_match = params[:name_to_match]
            @name_to_report = params.delete(:name_to_report) # not part of the protocol message
            super
          end

          def handle_step_matches(params)
            params.map do |raw_step_match|
              step_definition = WireStepDefinition.new(@connection, raw_step_match)
              step_args = raw_step_match['args'].map do |raw_arg|
                StepArgument.new(raw_arg['val'], raw_arg['pos'])
              end
              step_match(step_definition, step_args) # convoluted!
            end
          end
          
          private
          
          def step_match(step_definition, step_args)
            StepMatch.new(step_definition, @name_to_match, @name_to_report, step_args)
          end
        end
      end
      
      def step_matches(name_to_match, name_to_report)
        handler = Requests::StepMatches.new(self)
        handler.execute :name_to_match => name_to_match, :name_to_report => name_to_report
      end

      def snippet_text(step_keyword, step_name, multiline_arg_class_name)
        request_params = { :step_keyword => step_keyword, :step_name => step_name, :multiline_arg_class => multiline_arg_class_name }

        make_request(:snippet_text, request_params) do
          def handle_snippet_text(text)
            text
          end
        end
      end
      
      def invoke(step_definition_id, args)
        request_params = { :id => step_definition_id, :args => args }

        make_request(:invoke, request_params) do
          def handle_success(params)
          end
          
          def handle_pending(message)
            raise Pending, message || "TODO"
          end
          
          def handle_diff(tables)
            table1 = Ast::Table.new(tables[0])
            table2 = Ast::Table.new(tables[1])
            begin
              table1.diff!(table2)
            rescue Cucumber::Ast::Table::Different
              @connection.diff_failed
            end
            @connection.diff_ok
          end
        
          def handle_step_failed(params)
            handle_fail(params)
          end
        end
      end
      
      def diff_failed
        make_request(:diff_failed) do
          def handle_success(params)
          end
          
          def handle_step_failed(params)
            handle_fail(params)
          end
        end
      end
      
      def diff_ok
        make_request(:diff_ok) do
          def handle_success(params)
          end
          
          def handle_step_failed(params)
            handle_fail(params)
          end
        end
      end
      
      def begin_scenario(scenario)
        make_request(:begin_scenario) do
          def handle_success(params)
          end
        end
      end

      def end_scenario
        make_request(:end_scenario) do
          def handle_success(params)
          end
        end
      end
      
      private
      
      def make_request(request_message, params = nil, &block)
        handler = RequestHandler.new(self, request_message, &block)
        handler.execute(params)
      end
    end
  end
end