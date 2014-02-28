require 'delegate'
module Cucumber
  module MultilineArgument
    def self.from(core_multiline_arg)
      Builder.new(core_multiline_arg).result
    end

    class Builder
      def initialize(multiline_arg)
        multiline_arg.describe_to self
      end

      def doc_string(string, *args)
        @result = DocString.new(string)
      end

      def data_table(table, *args)
        @result = DataTable.new(table)
      end

      def result
        @result || None.new
      end
    end

    class DocString < SimpleDelegator
      def append_to(array)
        array << self
      end
    end

    class DataTable < SimpleDelegator
      def append_to(array)
        array << self
      end

      def to_json(options)
        raw.to_json(options)
      end
    end

    class None
      def append_to(array)
      end

      def describe_to(visitor)
      end
    end

  end
end

