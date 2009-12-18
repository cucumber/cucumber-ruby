require 'cucumber/wire_support/request_handler'
module Cucumber
  module WireSupport
    module WireProtocol
      module Requests
        class StepMatches < RequestHandler
          def execute(name_to_match, name_to_report)
            @name_to_match, @name_to_report = name_to_match, name_to_report
            request_params = {
              :name_to_match => name_to_match
            }
            super(request_params)
          end

          def handle_step_matches(params)
            params.map do |raw_step_match|
              step_definition = WireStepDefinition.new(@connection, raw_step_match)
              step_args = raw_step_match['args'].map do |raw_arg|
                StepArgument.new(raw_arg['val'], raw_arg['pos'])
              end
              step_match(step_definition, step_args)
            end
          end
        
          private
        
          def step_match(step_definition, step_args)
            StepMatch.new(step_definition, @name_to_match, @name_to_report, step_args)
          end
        end

        class SnippetText < RequestHandler
          def execute(step_keyword, step_name, multiline_arg_class_name)
            request_params = { 
              :step_keyword => step_keyword, 
              :step_name => step_name, 
              :multiline_arg_class => multiline_arg_class_name 
            }
            super(request_params)
          end
        
          def handle_snippet_text(text)
            text
          end
        end

        class Invoke < RequestHandler
          def execute(step_definition_id, args)
            request_params = { 
              :id => step_definition_id, 
              :args => args
            }
            super(request_params)
          end

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

        class DiffFailed < RequestHandler
          def handle_success(params)
          end
        
          def handle_step_failed(params)
            handle_fail(params)
          end
        end
      
        class DiffOk < RequestHandler
          def handle_success(params)
          end
        
          def handle_step_failed(params)
            handle_fail(params)
          end
        end
      
        class BeginScenario < RequestHandler
          def execute(scenario)
            super(nil) # not passing the scenario yet
          end

          def handle_success(params)
          end
        end

        class EndScenario < RequestHandler
          def handle_success(params)
          end
        end
      end
    end
  end
end