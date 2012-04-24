
module Cucumber
  module Formatter
    module Interceptor
      class Pipe
        attr_reader :pipe, :buffer
        def initialize(pipe)
          @pipe = pipe
          @buffer = []
          @wrapped = true
        end

        def write(str)
          @buffer << str if @wrapped
          return @pipe.write(str)
        end

        def unwrap!
          @wrapped = false
          @pipe
        end

        def method_missing(method, *args, &blk)
          @pipe.send(method, *args, &blk)
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
            $stdout = wrapped.unwrap!
          when :stderr
            wrapped = $stderr
            $stderr = wrapped.unwrap!
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
      end
    end
  end
end
