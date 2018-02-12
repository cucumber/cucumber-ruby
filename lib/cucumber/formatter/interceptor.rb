# frozen_string_literal: true

module Cucumber
  module Formatter
    module Interceptor
      class Pipe
        attr_reader :pipe
        def initialize(pipe)
          @pipe = pipe
          @buffer = StringIO.new
          @wrapped = true
        end

        def write(str)
          lock.synchronize do
            @buffer << str if @wrapped
            return @pipe.write(str)
          end
        end

        # @deprecated use #buffer_string
        def buffer
          require 'cucumber/deprecate.rb'
          Cucumber.deprecate(
            'Use Cucumber::Formatter::Interceptor::Pipe#buffer_string instead',
            'Cucumber::Formatter::Interceptor::Pipe#buffer',
            '3.99'
          )
          lock.synchronize do
            return @buffer.string.lines
          end
        end

        def buffer_string
          lock.synchronize do
            return @buffer.string.dup
          end
        end

        def unwrap!
          @wrapped = false
          @pipe
        end

        def method_missing(method, *args, &blk)
          @pipe.send(method, *args, &blk)
        end

        def respond_to?(method, include_private = false)
          super || @pipe.respond_to?(method, include_private)
        end

        def self.validate_pipe(pipe)
          unless [:stdout, :stderr].include? pipe
            raise ArgumentError, '#wrap only accepts :stderr or :stdout'
          end
        end

        def self.unwrap!(pipe)
          validate_pipe pipe
          wrapped = nil
          case pipe
          when :stdout
            wrapped = $stdout
            $stdout = wrapped.unwrap! if $stdout.respond_to?(:unwrap!)
          when :stderr
            wrapped = $stderr
            $stderr = wrapped.unwrap! if $stderr.respond_to?(:unwrap!)
          end
          wrapped
        end

        def self.wrap(pipe)
          validate_pipe pipe

          case pipe
          when :stderr
            $stderr = self.new($stderr)
            return $stderr
          when :stdout
            $stdout = self.new($stdout)
            return $stdout
          end
        end

        private

        def lock
          @lock ||= Mutex.new
        end
      end
    end
  end
end
