require 'delegate'
require 'cucumber/multiline_argument/data_table'
require 'cucumber/multiline_argument/doc_string'
require 'gherkin/rubify'

module Cucumber
  module MultilineArgument
    extend Gherkin::Rubify

    def self.from_core(node)
      Builder.new(node).result
    end

    def self.from(argument, location)
      return None.new unless argument
      return argument if argument.respond_to?(:to_step_definition_arg)
      argument = rubify(argument)
      case argument
      when String
        DocString.new(Core::Ast::DocString.new(argument, 'text/plain', location))
      when ::Gherkin::Formatter::Model::DocString
        DocString.new(argument.value, argument.content_type, location.on_line(argument.line_range))
      when Array
        location = location.on_line(argument.first.line..argument.last.line)
        DataTable.new(argument.map{|row| row.cells}, location)
      else
        raise ArgumentError, "Don't know how to convert #{argument.inspect} into a MultilineArgument"
      end
    end

    class Builder
      def initialize(multiline_arg)
        multiline_arg.describe_to self
      end

      def doc_string(node, *args)
        @result = DocString.new(node)
      end

      def data_table(node, *args)
        @result = DataTable.new(node)
      end

      def result
        @result || None.new
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

require 'cucumber/ast'
