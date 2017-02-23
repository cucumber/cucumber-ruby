require 'securerandom'
require 'socket'

module Cucumber
  module Formatter
    class EventStream

      def initialize(config, options)
        @config = config
        @io = if options.key?('port')
                open_socket(options['host'] || 'localhost', options['port'].to_i)
              else
                config.out_stream
              end
        @series = SecureRandom.uuid

        current_test_case = nil

        write_event type: "start"

        config.on_event :test_run_starting, -> (event) {
          write_event \
          type: "test-run-starting",
          workingDirectory: Dir.pwd,
          testCases: event.test_cases.map { |test_case|
            {
              location: test_case.location,
              testSteps: test_case.test_steps.map { |test_step|
                {
                  sourceLocation: test_step.source.last.location,
                  actionLocation: test_step.action_location,
                }
              }
            }
          }
        }

        config.on_event :test_case_starting, -> (event) {
          current_test_case = event.test_case # TODO: add this to the core step events so we don't have to cache it here
          write_event \
            type: "test-case-starting",
            location: event.test_case.location
        }

        config.on_event :test_step_finished, -> (event) {
          write_event \
            type: "test-step-finished",
            sourceLocation: event.test_step.source.last.location,
            actionLocation: event.test_step.action_location,
            testCase: {
              location: current_test_case.location
            },
            result: {
              status: event.result.to_sym.to_s,
              duration: event.result.duration.nanoseconds
            }
        }

        config.on_event :test_case_finished, -> (event) {
          write_event \
            type: "test-case-finished", 
            location: event.test_case.location,
            result: {
              status: event.result.to_sym.to_s,
              duration: event.result.duration.nanoseconds
            }
        }

        config.on_event :test_run_finished, -> (event) {
          @io.close if @io.is_a?(TCPSocket)
        }

      end

      private

      def open_socket(port, host)
        TCPSocket.new(port, host)
      end

      def write_event(attributes)
        data = attributes.merge({
          series: @series,
          timestamp: Time.now.to_i
        })
        @io.puts data.to_json
      end
    end
  end
end

