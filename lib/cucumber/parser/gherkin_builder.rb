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
        ast_feature
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

      def background(node)
        @background_builder = BackgroundBuilder.new(file, node)
        @step_container = @background_builder
      end

      def scenario(node)
        @scenario_builder = ScenarioBuilder.new(file, node)
        add_child @scenario_builder
        @step_container = @scenario_builder
      end

      def scenario_outline(node)
        @scenario_outline_builder = ScenarioOutlineBuilder.new(file, node)
        add_child @scenario_outline_builder
        @step_container = @scenario_outline_builder
      end

      def examples(examples)
        examples_fields = [
          Ast::Location.new(file, examples.line),
          Ast::Comment.new(examples.comments.map{|comment| comment.value}.join("\n")),
          examples.keyword,
          examples.name,
          examples.description,
          matrix(examples.rows)
        ]
        @scenario_outline_builder.add_examples(examples_fields, examples)
      end

      def step(node)
        @step_builder = StepBuilder.new(file, node)
        @step_container.add_child(@step_builder)
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
        background = ast_background(language)
        tags = Ast::Tags.new(nil, @gherkin_feature.tags)
        feature ||= Ast::Feature.new(
          Ast::Location.new(file, @gherkin_feature.line),
          background,
          Ast::Comment.new(@gherkin_feature.comments.map{|comment| comment.value}.join("\n")),
          tags,
          @gherkin_feature.keyword,
          @gherkin_feature.name.lstrip,
          @gherkin_feature.description.rstrip,
          children.map { |builder| builder.result(background, language, tags) }
        )
        feature.gherkin_statement(@gherkin_feature)
        feature.language = language
        feature
      end

      def language
        @language || raise("Language has not been set")
      end

      def ast_background(language)
        return Ast::EmptyBackground.new unless @background_builder
        @background_builder.result(language)
      end

      def file
        if Cucumber::WINDOWS && file && !ENV['CUCUMBER_FORWARD_SLASH_PATHS']
          @path.gsub(/\//, '\\')
        else
          @path
        end
      end

      def add_child(child)
        children << child
      end

      def children
        @children ||= []
      end

      class Builder
        def initialize(file, node)
          @file, @node = file, node
          @steps = []
        end

        def add_step(step)
          steps << step
        end

        private

        attr_reader :file, :node, :steps
      end

      class BackgroundBuilder < Builder
        def result(language)
          return @result if @result
          background = Ast::Background.new(
            language,
            Ast::Location.new(file, node.line),
            Ast::Comment.new(node.comments.map{|comment| comment.value}.join("\n")),
            node.keyword,
            node.name,
            node.description,
            steps(language)
          )
          background.gherkin_statement(node)
          @result = background
        end

        def steps(language)
          children.map { |child| child.result(language) }
        end

        def add_child(child)
          children << child
        end

        def children
          @children ||= []
        end

      end

      class ScenarioBuilder < Builder
        def result(background, language, feature_tags)
          scenario = Ast::Scenario.new(
            language,
            Ast::Location.new(file, node.line),
            background,
            Ast::Comment.new(node.comments.map{|comment| comment.value}.join("\n")),
            Ast::Tags.new(nil, node.tags),
            feature_tags,
            node.keyword,
            node.name,
            node.description,
            steps(language)
          )
          scenario.gherkin_statement(node)
          scenario
        end

        def steps(language)
          children.map { |child| child.result(language) }
        end

        def add_child(child)
          children << child
        end

        def children
          @children ||= []
        end
      end

      class ScenarioOutlineBuilder < Builder
        def result(background, language, feature_tags)
          scenario_outline = Ast::ScenarioOutline.new(
            language,
            Ast::Location.new(file, node.line),
            background,
            Ast::Comment.new(node.comments.map{|comment| comment.value}.join("\n")),
            Ast::Tags.new(nil, node.tags),
            feature_tags,
            node.keyword,
            node.name,
            node.description,
            steps(language),
            examples_sections
          )
          scenario_outline.gherkin_statement(node)
          scenario_outline
        end

        def add_examples(examples_section, node)
          @examples_sections ||= []
          @examples_sections << [examples_section, node]
        end

        def steps(language)
          children.map { |child| child.result(language) }
        end

        def add_child(child)
          children << child
        end

        def children
          @children ||= []
        end

        private

        attr_reader :examples_sections
      end

      class StepBuilder < Builder
        def result(language)
          step = Ast::Step.new(
            language,
            Ast::Location.new(file, node.line),
            node.keyword,
            node.name,
            Ast::MultilineArgument.from(node.doc_string || node.rows)
          )
          step.gherkin_statement(node)
          step
        end
      end

    end
  end
end
