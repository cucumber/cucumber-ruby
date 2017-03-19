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

        config.on_event :gherkin_source_read, -> (event) {
          write_event \
          type: "source",
          uri: event.path,
          data: event.body,
          media: {
            encoding: 'utf-8',
            type: 'text/vnd.cucumber.gherkin+plain'
          }
        }

        config.on_event :test_run_starting, -> (event) {
          write_event \
            type: "test-run-started",
            workingDirectory: Dir.pwd,
            timestamp: Time.now.to_i

          event.test_cases.each { |test_case|
            write_event \
              type: "test-case",
              sourceLocation: location_to_json(test_case.location),
              steps: test_case.test_steps.map { |test_step|
                test_step_to_json(test_case, test_step)
              }
          }
        }

        config.on_event :test_case_starting, -> (event) {
          current_test_case = event.test_case # TODO: add this to the core step events so we don't have to cache it here
          write_event \
            type: "test-case-started",
            sourceLocation: location_to_json(event.test_case.location)
        }

        config.on_event :test_step_starting, -> (event) {
          write_event \
            type: "test-step-started",
            testCase: { sourceLocation: location_to_json(current_test_case.location) },
            index: current_test_case.test_steps.index(event.test_step)
        }

        config.on_event :test_step_finished, -> (event) {
          write_event \
            type: "test-step-finished",
            testCase: { sourceLocation: location_to_json(current_test_case.location) },
            index: current_test_case.test_steps.index(event.test_step),
            result: result_to_json(event.result)
        }

        config.on_event :test_case_finished, -> (event) {
          write_event \
            type: "test-case-finished",
            sourceLocation: location_to_json(event.test_case.location),
            result: result_to_json(event.result)
        }

        config.on_event :test_run_finished, -> (event) {
          @io.close if @io.is_a?(TCPSocket)
        }

      end

      private

      def result_to_json(result)
        data = {
          status: result.to_sym.to_s,
          duration: result.duration.nanoseconds
        }
        if result.respond_to?(:exception)
          data[:exception] = {
            message: result.exception.message,
            type: result.exception.class,
            stackTrace: result.exception.backtrace
          }
        end
        data
      end

      def test_step_to_json(test_case, test_step)
        {
          actionLocation: location_to_json(test_step.action_location),
          sourceLocation: location_to_json(test_step.source.last.location)
        }
      end

      def open_socket(port, host)
        TCPSocket.new(port, host)
      end

      def write_event(attributes)
        @io.puts attributes.to_json
      end

      def location_to_json(location)
        { uri: location.file, line: location.line }
      end
    end
  end
end

