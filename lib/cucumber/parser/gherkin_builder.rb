require 'cucumber/ast'
require 'gherkin/rubify'
require 'cucumber/ast/multiline_argument'

module Cucumber
  module Parser
    # This class conforms to the Gherkin event API and builds the
    # "legacy" AST. It will be replaced later when we have a new "clean"
    # AST.
    class GherkinBuilder
      include Gherkin::Rubify

      def ast
        @feature || @multiline_arg
      end

      def feature(feature)
        @feature = Ast::Feature.new(
          nil,
          Ast::Comment.new(feature.comments.map{|comment| comment.value}.join("\n")),
          Ast::Tags.new(nil, feature.tags),
          feature.keyword,
          feature.name.lstrip,
          feature.description.rstrip,
          []
        )
        @feature.gherkin_statement(feature)
        @feature
      end

      def background(background)
        @background = Ast::Background.new(
          Ast::Comment.new(background.comments.map{|comment| comment.value}.join("\n")),
          background.line,
          background.keyword,
          background.name,
          background.description,
          []
        )
        @feature.background = @background
        @background.feature = @feature
        @step_container = @background
        @background.gherkin_statement(background)
      end

      def scenario(statement)
        scenario = Ast::Scenario.new(
          @background,
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")),
          Ast::Tags.new(nil, statement.tags),
          statement.line,
          statement.keyword,
          statement.name,
          statement.description,
          []
        )
        @feature.add_feature_element(scenario)
        @background.feature_elements << scenario if @background
        @step_container = scenario
        scenario.gherkin_statement(statement)
      end

      def scenario_outline(statement)
        scenario_outline = Ast::ScenarioOutline.new(
          @background,
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")),
          Ast::Tags.new(nil, statement.tags),
          statement.line,
          statement.keyword,
          statement.name,
          statement.description,
          [],
          []
        )
        @feature.add_feature_element(scenario_outline)
        if @background
          @background = @background.dup
          @background.feature_elements << scenario_outline
        end
        @step_container = scenario_outline
        scenario_outline.gherkin_statement(statement)
      end

      def examples(examples)
        examples_fields = [
          Ast::Comment.new(examples.comments.map{|comment| comment.value}.join("\n")),
          examples.line,
          examples.keyword,
          examples.name,
          examples.description,
          matrix(examples.rows)
        ]
        @step_container.add_examples(examples_fields, examples)
      end

      def step(gherkin_step)
        step = Ast::Step.new(
          gherkin_step.line,
          gherkin_step.keyword,
          gherkin_step.name,
          Ast::MultilineArgument.from(gherkin_step.doc_string || gherkin_step.rows)
        )
        step.gherkin_statement(gherkin_step)
        @step_container.add_step(step)
      end

      def eof
      end

      def syntax_error(state, event, legal_events, line)
        # raise "SYNTAX ERROR"
      end

    private

      def matrix(gherkin_table)
        gherkin_table.map do |gherkin_row|
          row = gherkin_row.cells
          class << row
            attr_accessor :line
          end
          row.line = gherkin_row.line
          row
        end
      end
    end
  end
end
