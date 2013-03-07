require 'cucumber/ast'
require 'gherkin/rubify'
require 'cucumber/ast/multiline_argument'
require 'cucumber/ast/empty_background'

module Cucumber
  module Parser
    # This class conforms to the Gherkin event API and builds the
    # "legacy" AST. It will be replaced later when we have a new "clean"
    # AST.
    class GherkinBuilder
      include Gherkin::Rubify
      def initialize(path = 'UNKNOWN-FILE')
        @path = path
      end

      def result
        ast_feature || @multiline_arg
      end

      def language=(language)
        @language = language
      end

      def feature(feature)
        @gherkin_feature = feature
      end

      def uri(uri)
        @path = uri
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
        @background.gherkin_statement(background)
        @step_container = @background
      end

      def scenario(statement)
        scenario = Ast::Scenario.new(
          ast_background,
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")),
          Ast::Tags.new(nil, statement.tags),
          statement.line,
          statement.keyword,
          statement.name,
          statement.description,
          []
        )
        ast_feature.add_feature_element(scenario)
        @step_container = scenario
        scenario.gherkin_statement(statement)
      end

      def scenario_outline(statement)
        scenario_outline = Ast::ScenarioOutline.new(
          ast_background,
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")),
          Ast::Tags.new(nil, statement.tags),
          statement.line,
          statement.keyword,
          statement.name,
          statement.description,
          [],
          []
        )
        ast_feature.add_feature_element(scenario_outline)
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
      if defined?(JRUBY_VERSION)
        java_import java.util.ArrayList
        ArrayList.__persistent__ = true
      end

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

      def ast_feature
        return unless @gherkin_feature
        @feature ||= Ast::Feature.new(
          ast_background,
          Ast::Comment.new(@gherkin_feature.comments.map{|comment| comment.value}.join("\n")),
          Ast::Tags.new(nil, @gherkin_feature.tags),
          @gherkin_feature.keyword,
          @gherkin_feature.name.lstrip,
          @gherkin_feature.description.rstrip,
          []
        )
        @feature.gherkin_statement(@gherkin_feature)
        @feature.file = @path
        @feature.language = @language
        @feature
      end

      def ast_background
        @background ||= Ast::EmptyBackground.new
      end
    end
  end
end
