require 'gherkin3/token_scanner'
require 'gherkin3/token_matcher'
require 'gherkin3/ast_builder'
require 'gherkin3/parser'

module Cucumber
  module Gherkin
    class StepsParser
      def initialize(builder, language)
        @builder = builder
        @language = language
      end
      def parse(text)
        ast_builder = ::Gherkin3::AstBuilder.new
        context = ::Gherkin3::ParserContext.new(
          ::Gherkin3::TokenScanner.new(text),
          ast_builder,
          ::Gherkin3::TokenMatcher.new(@language),
          [],
          []
          )
        parser = ::Gherkin3::Parser.new

        parser.start_rule(context, :ScenarioDefinition)
        parser.start_rule(context, :Scenario)
        scenario = ast_builder.current_node
        state = 12
        token = nil
        begin
          token = parser.read_token(context)
          state = parser.match_token(state, token, context)
        end until(token.eof?)

        raise CompositeParserException.new(context.errors) if context.errors.any?

        @builder.steps(ast_builder.get_steps(scenario))
      end
    end
  end
end
