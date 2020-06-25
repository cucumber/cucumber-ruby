# frozen_string_literal: true

require 'cucumber/formatter/query/pickle_by_test'
require 'cucumber/formatter/query/pickle_step_by_test_step'

module Cucumber
  module Formatter
    class AstLookup
      def initialize(config)
        @gherkin_documents = {}
        @scenario_by_id = {}
        @step_by_ids = {}
        @step_keyword_by_id = {}
        @example_row_by_id = {}
        @example_table_by_row_id = {}
        @pickle_by_test = Query::PickleByTest.new(config)
        @pickle_step_by_test_step = Query::PickleStepByTestStep.new(config)

        config.on_event :envelope, &method(:on_envelope)
      end

      def gherkin_document(uri)
        @gherkin_documents[uri]
      end

      def scenario_source(test_case)
        pickle = @pickle_by_test.pickle(test_case)
        if pickle.ast_node_ids.count == 1
          return ScenarioSource.new(
            :Scenario,
            @scenario_by_id[pickle.ast_node_ids[0]]
          )
        end

        ScenarioOutlineSource.new(
          :ScenarioOutline,
          @scenario_by_id[pickle.ast_node_ids[0]],
          @example_table_by_row_id[pickle.ast_node_ids[1]],
          @example_row_by_id[pickle.ast_node_ids[1]]
        )
      end

      def step_source(test_step)
        pickle_step = @pickle_step_by_test_step.pickle_step(test_step)
        StepSource.new(
          :Step,
          @step_by_ids[pickle_step.ast_node_ids[0]]
        )
      end

      def snippet_step_keyword(test_step)
        pickle_step = @pickle_step_by_test_step.pickle_step(test_step)
        Cucumber::Gherkin::I18n.code_keyword_for(@step_keyword_by_id[pickle_step.ast_node_ids[0]])
      end

      ScenarioSource = Struct.new(:type, :scenario)
      ScenarioOutlineSource = Struct.new(:type, :scenario_outline, :examples, :row)
      StepSource = Struct.new(:type, :step)

      private

      def on_envelope(event)
        envelope = event.envelope

        return unless envelope.gherkin_document
        gherkin_document = envelope.gherkin_document
        @gherkin_documents[gherkin_document.uri] = gherkin_document

        return unless gherkin_document.feature
        dialect = ::Gherkin::Dialect.for(gherkin_document.feature.language)
        @given_when_then_keywords = [
          dialect.given_keywords,
          dialect.when_keywords,
          dialect.then_keywords
        ].flatten.uniq.reject { |kw| kw == '* ' }

        walk_feature(gherkin_document.feature)
      end

      def walk_feature(feature)
        feature.children.each do |child|
          @feature_background_keyword = walk_background(child.background) if child.background
          walk_scenario(child.scenario) if child.scenario
          walk_rule(child.rule) if child.rule
        end

        @feature_background_keyword = nil
      end

      def walk_background(background)
        walk_steps(background.steps)
      end

      def walk_scenario(scenario)
        @scenario_by_id[scenario.id] = scenario
        walk_steps(scenario.steps)

        scenario.examples.each do |example_table|
          example_table.table_body.each do |row|
            @example_row_by_id[row.id] = row
            @example_table_by_row_id[row.id] = example_table
          end
        end
      end

      def walk_rule(rule)
        rule.children.each do |rule_child|
          @rule_background_keyword = walk_background(rule_child.background) if rule_child.background
          walk_scenario(rule_child.scenario) if rule_child.scenario
        end
        @rule_background_keyword = nil
      end

      def walk_steps(steps)
        current_keyword = @rule_background_keyword || @feature_background_keyword || @given_when_then_keywords.first

        steps.each do |step|
          current_keyword = step.keyword if @given_when_then_keywords.include?(step.keyword)

          @step_by_ids[step.id] = step
          @step_keyword_by_id[step.id] = current_keyword
        end

        current_keyword
      end
    end
  end
end
