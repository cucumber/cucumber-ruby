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

        # TODO: add protocol version, working directory
        write_event type: "start"

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

        # TODO: instead of one message, emit a series of pickle events, one for each test case (including hooks as steps)
        config.on_event :test_run_starting, -> (event) {
          event.test_cases.each { |test_case|
            write_event \
              type: "pickle",
              uri: test_case.location.file,
              pickle: {
                name: test_case.name,
                steps: test_case.test_steps.map { |test_step|
                  test_step_to_json(test_step)
                },
                tags: test_case.tags.map { |tag|
                  {
                    name: tag.name,
                    location: location_to_json(tag.location, test_case.location.file)
                  }
                },
                locations: [
                  location_to_json(test_case.location, test_case.location.file)
                ]
              }
          }
        }

        config.on_event :test_case_starting, -> (event) {
          current_test_case = event.test_case # TODO: add this to the core step events so we don't have to cache it here
          write_event \
            type: "test-case-starting",
            location: event.test_case.location
        }

        config.on_event :test_step_starting, -> (event) {
          write_event \
            type: "test-step-starting",
            index: current_test_case.test_steps.index(event.test_step),
            testCase: {
              location: current_test_case.location
            }
        }

        config.on_event :test_step_finished, -> (event) {
          write_event \
            type: "test-step-finished",
            index: current_test_case.test_steps.index(event.test_step),
            testCase: {
              location: current_test_case.location
            },
            result: result_to_json(event.result)
        }

        config.on_event :test_case_finished, -> (event) {
          write_event \
            type: "test-case-finished", 
            location: event.test_case.location,
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

      def location_to_json(location, parent_file)
        result = { line: location.line }
        result[:uri] = location.file if location.file != parent_file
        result
      end

      # TODO: use a plain location with line / colon for gherkin steps, use URI as well for hooks
      def test_step_to_json(test_step)
        if hook?(test_step)
          {
            locations: [
              location_to_json(test_step.action_location, test_step.location.file)
            ]
          }
        else
          {
            text: test_step.name,
            locations: [
              location_to_json(test_step.source.last.location, test_step.location.file),
              location_to_json(test_step.action_location, test_step.location.file)
            ]
          }
        end
      end

      def hook?(test_step)
        not test_step.source.last.respond_to?(:actual_keyword)
      end

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

