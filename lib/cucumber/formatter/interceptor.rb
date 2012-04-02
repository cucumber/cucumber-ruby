
module Cucumber
  module Formatter
    module Interceptor
      class Pipe
        attr_reader :pipe, :buffer
        def initialize(pipe)
          @pipe = pipe
          @buffer = []
        end

        def write(str)
          @buffer << str
          return @pipe.write(str)
        end

        def method_missing(method, *args, &blk)
          @pipe.send(method, *args, &blk)
        end
      end
    end
  end
end
