require 'gherkin/rubify'

module Cucumber
  module Ast
    module MultilineArgument

      class << self
        include Gherkin::Rubify

        def from(argument)
          return unless argument
          return argument if argument.respond_to?(:to_step_definition_arg)

          case(rubify(argument))
          when String
            # TODO: this duplicates work that gherkin does. We should really pass the string to gherkin and let it parse it.
            Ast::DocString.new(argument, '')
          when Gherkin::Formatter::Model::DocString
            Ast::DocString.new(argument.value, argument.content_type)
          when Array
            Ast::Table.new(argument.map{|row| row.cells})
          else
            raise ArgumentError, "Don't know how to convert #{argument} into a MultilineArgument"
          end
        end

      end
    end
  end
end
