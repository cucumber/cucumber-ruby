# frozen_string_literal: true

require 'cucumber/formatter/query/pickle_by_test'

module Cucumber
  module Formatter
    class AstLookup
      def initialize(config)
        @gherkin_documents = {}
        @scenario_by_ids = {}
        @example_row_by_ids = {}
        @example_table_by_row_id = {}
        @pickle_by_test = Query::PickleByTest.new(config)

        config.on_event :envelope, &method(:on_envelope)

        @test_case_lookups = {}
        @test_step_lookups = {}
        @step_keyword_lookups = {}
      end

      def gherkin_document(uri)
        @gherkin_documents[uri]
      end

      def scenario_source(test_case)
        pickle = @pickle_by_test.pickle(test_case)
        if pickle.ast_node_ids.count == 1
          return ScenarioSource.new(
            :Scenario,
            @scenario_by_ids[pickle.ast_node_ids[0]]
          )
        end

        ScenarioOutlineSource.new(
          :ScenarioOutline,
          @scenario_by_ids[pickle.ast_node_ids[0]],
          @example_table_by_row_id[pickle.ast_node_ids[1]],
          @example_row_by_ids[pickle.ast_node_ids[1]]
        )
      end

      def step_source(test_step)
        uri = test_step.location.file
        @test_step_lookups[uri] ||= TestStepLookupBuilder.new(gherkin_document(uri)).lookup_hash
        @test_step_lookups[uri][test_step.location.lines.min]
      end

      def snippet_step_keyword(test_step)
        uri = test_step.location.file
        document = gherkin_document(uri)
        dialect = ::Gherkin::Dialect.for(document.feature.language)
        given_when_then_keywords = [dialect.given_keywords, dialect.when_keywords, dialect.then_keywords].flatten.uniq.reject { |kw| kw == '* ' }
        keyword_lookup = step_keyword_lookup(uri)
        keyword = nil
        node = keyword_lookup[test_step.location.lines.min]
        while keyword.nil?
          if given_when_then_keywords.include?(node.keyword)
            keyword = node.keyword
            break
          end
          break if node.previous_node.nil?
          node = node.previous_node
        end
        keyword = dialect.given_keywords.reject { |kw| kw == '* ' }[0] if keyword.nil?
        keyword = Cucumber::Gherkin::I18n.code_keyword_for(keyword)
        keyword
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

        gherkin_document.feature.children.each do |child|
          walk_rule(child.rule) if child.rule
          walk_scenario(child.scenario) if child.scenario
        end
      end

      def walk_scenario(scenario)
        @scenario_by_ids[scenario.id] = scenario

        scenario.examples.each do |example_table|
          example_table.table_body.each do |row|
            @example_row_by_ids[row.id] = row
            @example_table_by_row_id[row.id] = example_table
          end
        end
      end

      def walk_rule(rule)
        rule.children.each do |rule_child|
          walk_scenario(rule_child.scenario) if rule_child.scenario
        end
      end

      def step_keyword_lookup(uri)
        @step_keyword_lookups[uri] ||= KeywordLookupBuilder.new(gherkin_document(uri)).lookup_hash
      end

      class TestCaseLookupBuilder
        attr_reader :lookup_hash

        def initialize(gherkin_document)
          @lookup_hash = {}
          process_scenario_container(gherkin_document.feature)
        end

        private

        def process_scenario_container(container)
          container.children.each do |child|
            if child.respond_to?(:rule) && child.rule
              process_scenario_container(child.rule)
            elsif child.respond_to?(:scenario) && child.scenario
              process_scenario(child)
            end
          end
        end

        def process_scenario(child)
          if child.scenario.examples.empty?
            @lookup_hash[child.scenario.location.line] = ScenarioSource.new(:Scenario, child.scenario)
          else
            child.scenario.examples.each do |examples|
              examples.table_body.each do |row|
                @lookup_hash[row.location.line] = ScenarioOutlineSource.new(:ScenarioOutline, child.scenario, examples, row)
              end
            end
          end
        end
      end

      class TestStepLookupBuilder
        attr_reader :lookup_hash

        def initialize(gherkin_document)
          @lookup_hash = {}
          process_scenario_container(gherkin_document.feature)
        end

        private

        def process_scenario_container(container)
          container.children.each do |child|
            if child.respond_to?(:rule) && child.rule
              process_scenario_container(child.rule)
            elsif child.respond_to?(:scenario) && child.scenario
              child.scenario.steps.each do |step|
                @lookup_hash[step.location.line] = StepSource.new(:Step, step)
              end
            elsif !child.background.nil?
              child.background.steps.each do |step|
                @lookup_hash[step.location.line] = StepSource.new(:Step, step)
              end
            end
          end
        end
      end

      KeywordSearchNode = Struct.new(:keyword, :previous_node)

      class KeywordLookupBuilder
        attr_reader :lookup_hash

        def initialize(gherkin_document)
          @lookup_hash = {}
          process_scenario_container(gherkin_document.feature, nil)
        end

        private

        # rubocop:disable Metrics/PerceivedComplexity
        def process_scenario_container(container, original_previous_node)
          container.children.each do |child|
            previous_node = original_previous_node
            if child.respond_to?(:rule) && child.rule
              process_scenario_container(child.rule, original_previous_node)
            elsif child.respond_to?(:scenario) && child.scenario
              child.scenario.steps.each do |step|
                node = KeywordSearchNode.new(step.keyword, previous_node)
                @lookup_hash[step.location.line] = node
                previous_node = node
              end
            elsif child.respond_to?(:background) && child.background
              child.background.steps.each do |step|
                node = KeywordSearchNode.new(step.keyword, previous_node)
                @lookup_hash[step.location.line] = node
                previous_node = node
                original_previous_node = previous_node
              end
            end
          end
        end
        # rubocop:enable Metrics/PerceivedComplexity
      end
    end
  end
end
