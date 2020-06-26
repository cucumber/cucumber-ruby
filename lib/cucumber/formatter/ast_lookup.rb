# frozen_string_literal: true

require 'cucumber/formatter/query/pickle_by_test'
require 'cucumber/formatter/query/pickle_step_by_test_step'
require 'cucumber/gherkin/document_walker'

module Cucumber
  module Formatter
    class AstLookup
      def initialize(config)
        @step_keyword_by_id = {}

        @pickle_by_test = Query::PickleByTest.new(config)
        @pickle_step_by_test_step = Query::PickleStepByTestStep.new(config)
        @ast_node_query = AstNodeQuery.new

        config.on_event :envelope, &method(:on_envelope)
      end

      def gherkin_document(uri)
        @ast_node_query.gherkin_documents[uri]
      end

      def scenario_source(test_case)
        pickle = @pickle_by_test.pickle(test_case)
        if pickle.ast_node_ids.count == 1
          return ScenarioSource.new(
            :Scenario,
            @ast_node_query.scenario_by_id[pickle.ast_node_ids[0]]
          )
        end

        ScenarioOutlineSource.new(
          :ScenarioOutline,
          @ast_node_query.scenario_by_id[pickle.ast_node_ids[0]],
          @ast_node_query.example_table_by_row_id[pickle.ast_node_ids[1]],
          @ast_node_query.example_row_by_id[pickle.ast_node_ids[1]]
        )
      end

      def step_source(test_step)
        pickle_step = @pickle_step_by_test_step.pickle_step(test_step)
        StepSource.new(
          :Step,
          @ast_node_query.step_by_id[pickle_step.ast_node_ids[0]]
        )
      end

      def snippet_step_keyword(test_step)
        pickle_step = @pickle_step_by_test_step.pickle_step(test_step)
        Cucumber::Gherkin::I18n.code_keyword_for(@ast_node_query.step_keyword_by_id[pickle_step.ast_node_ids[0]])
      end

      ScenarioSource = Struct.new(:type, :scenario)
      ScenarioOutlineSource = Struct.new(:type, :scenario_outline, :examples, :row)
      StepSource = Struct.new(:type, :step)

      private

      def on_envelope(event)
        envelope = event.envelope

        return unless envelope.gherkin_document
        Gherkin::DocumentWalker.new(@ast_node_query).walk_gherkin_document(envelope.gherkin_document)
      end
    end

    class AstNodeQuery < Gherkin::AstNodeHandler
      attr_reader :gherkin_documents
      attr_reader :scenario_by_id
      attr_reader :step_by_id
      attr_reader :step_keyword_by_id
      attr_reader :example_table_by_row_id
      attr_reader :example_row_by_id

      def initialize
        @gherkin_documents = {}
        @scenario_by_id = {}
        @step_by_id = {}
        @step_keyword_by_id = {}
        @example_table_by_row_id = {}
        @example_row_by_id = {}
        @default_keyword_by_context = {}
      end

      def handle_gherkin_document(gherkin_document, _node_path)
        @gherkin_documents[gherkin_document.uri] = gherkin_document

        dialect = ::Gherkin::Dialect.for(gherkin_document.feature.language)
        @given_when_then_keywords = [
          dialect.given_keywords,
          dialect.when_keywords,
          dialect.then_keywords
        ].flatten.uniq.reject { |kw| kw == '* ' }
      end

      def handle_scenario(scenario, node_path)
        @current_keyword = default_keyword(node_path)
        @scenario_by_id[scenario.id] = scenario
      end

      def handle_step(step, node_path)
        if @given_when_then_keywords.include?(step.keyword)
          @current_keyword = step.keyword

          background = find_background(node_path)
          if background
            context = find_background_context(node_path)
            @default_keyword_by_context[context] = step.keyword
          end
        end

        @step_by_id[step.id] = step
        @step_keyword_by_id[step.id] = @current_keyword
      end

      def handle_example_row(row, node_path)
        examples_table = find_closest_ancestor_by_class(
          node_path,
          Cucumber::Messages::GherkinDocument::Feature::Scenario::Examples
        )

        @example_table_by_row_id[row.id] = examples_table
        @example_row_by_id[row.id] = row
      end

      private

      def default_keyword(node_path)
        context = find_background_context(node_path)
        if context && @default_keyword_by_context[context]
          @default_keyword_by_context[context]
        else
          @given_when_then_keywords.first
        end
      end

      def find_closest_ancestor_by_class(node_path, cls)
        node_path.filter { |node| node.is_a?(cls) }.last
      end

      def find_background_context(node_path)
        rule = find_rule(node_path)
        return rule if rule
        find_feature(node_path)
      end

      def find_feature(node_path)
        find_closest_ancestor_by_class(
          node_path,
          Cucumber::Messages::GherkinDocument::Feature
        )
      end

      def find_background(node_path)
        find_closest_ancestor_by_class(
          node_path,
          Cucumber::Messages::GherkinDocument::Feature::Background
        )
      end

      def find_rule(node_path)
        find_closest_ancestor_by_class(
          node_path,
          Cucumber::Messages::GherkinDocument::Feature::FeatureChild::Rule
        )
      end
    end
  end
end
