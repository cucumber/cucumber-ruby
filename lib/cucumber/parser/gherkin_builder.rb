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
        return nil unless @feature_builder
        @feature_builder.result(language)
      end

      def language=(language)
        @language = language
      end

      def uri(uri)
        @path = uri
      end

      def feature(node)
        @feature_builder = FeatureBuilder.new(file, node)
      end

      def background(node)
        builder = BackgroundBuilder.new(file, node)
        @feature_builder.background_builder = builder
        @current = builder
      end

      def scenario(node)
        builder = ScenarioBuilder.new(file, node)
        @feature_builder.add_child builder
        @current = builder
      end

      def scenario_outline(node)
        builder = ScenarioOutlineBuilder.new(file, node)
        @feature_builder.add_child builder
        @current = builder
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
        @current.add_examples examples_fields, examples
      end

      def step(node)
        builder = StepBuilder.new(file, node)
        @current.add_child builder
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

      def language
        @language || raise("Language has not been set")
      end

      def file
        if Cucumber::WINDOWS && !ENV['CUCUMBER_FORWARD_SLASH_PATHS']
          @path.gsub(/\//, '\\')
        else
          @path
        end
      end

      class Builder
        def initialize(file, node)
          @file, @node = file, node
        end

        private

        def tags
          Ast::Tags.new(nil, node.tags)
        end

        def location
          Ast::Location.new(file, node.line)
        end

        def comment
          Ast::Comment.new(node.comments.map{ |comment| comment.value }.join("\n"))
        end

        attr_reader :file, :node
      end

      class FeatureBuilder < Builder
        def result(language)
          background = background(language)
          feature = Ast::Feature.new(
            location,
            background,
            comment,
            tags,
            node.keyword,
            node.name.lstrip,
            node.description.rstrip,
            children.map { |builder| builder.result(background, language, tags) }
          )
          feature.gherkin_statement(node)
          feature.language = language
          feature
        end

        def background_builder=(builder)
          @background_builder = builder
        end

        def add_child(child)
          children << child
        end

        def children
          @children ||= []
        end

        private

        def background(language)
          return Ast::EmptyBackground.new unless @background_builder
          @background ||= @background_builder.result(language)
        end
      end

      class BackgroundBuilder < Builder
        def result(language)
          background = Ast::Background.new(
            language,
            location,
            comment,
            node.keyword,
            node.name,
            node.description,
            steps(language)
          )
          background.gherkin_statement(node)
          background
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
            location,
            background,
            comment,
            tags,
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
            location,
            background,
            comment,
            tags,
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
            location,
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
