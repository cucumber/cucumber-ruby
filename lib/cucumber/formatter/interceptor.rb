
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
      end
    end
  end
end
