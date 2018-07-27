# frozen_string_literal: true

module Cucumber
  module Formatter
    class AstLookup
      def initialize(config)
        @gherkin_documents = {}
        @test_case_lookups = {}
        @test_step_lookups = {}
        @step_keyword_lookups = {}
        config.on_event :gherkin_source_parsed, &method(:on_gherkin_source_parsed)
      end

      def on_gherkin_source_parsed(event)
        @gherkin_documents[event.uri] = event.gherkin_document
      end

      def gherkin_document(uri)
        @gherkin_documents[uri]
      end

      def scenario_source(test_case)
        uri = test_case.location.file
        @test_case_lookups[uri] ||= create_test_case_lookup(gherkin_document(uri))
        @test_case_lookups[uri][test_case.location.lines.max]
      end

      def step_source(test_step)
        uri = test_step.location.file
        @test_step_lookups[uri] ||= create_test_step_lookup(gherkin_document(uri))
        @test_step_lookups[uri][test_step.location.lines.min]
      end

      def snippet_step_keyword(test_step)
        uri = test_step.location.file
        document = gherkin_document(uri)
        dialect = ::Gherkin::Dialect.for(document[:feature][:language])
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

      def step_keyword_lookup(uri)
        @step_keyword_lookups[uri] ||= create_keyword_lookup(gherkin_document(uri))
      end

      def create_test_case_lookup(gherkin_document)
        feature = gherkin_document[:feature]
        lookup_hash = {}
        feature[:children].each do |child|
          if child[:type] == :Scenario
            lookup_hash[child[:location][:line]] = ScenarioSource.new(:Scenario, child)
          elsif child[:type] == :ScenarioOutline
            child[:examples].each do |examples|
              examples[:tableBody].each do |row|
                lookup_hash[row[:location][:line]] = ScenarioOutlineSource.new(:ScenarioOutline, child, examples, row)
              end
            end
          end
        end
        lookup_hash
      end

      def create_test_step_lookup(gherkin_document)
        feature = gherkin_document[:feature]
        lookup_hash = {}
        feature[:children].each do |child|
          child[:steps].each do |step|
            lookup_hash[step[:location][:line]] = StepSource.new(:Step, step)
          end
        end
        lookup_hash
      end

      KeywordSearchNode = Struct.new(:keyword, :previous_node)

      def create_keyword_lookup(gherkin_document)
        lookup = {}
        original_previous_node = nil
        gherkin_document[:feature][:children].each do |child|
          previous_node = original_previous_node
          child[:steps].each do |step|
            node = KeywordSearchNode.new(step[:keyword], previous_node)
            lookup[step[:location][:line]] = node
            previous_node = node
          end
          original_previous_node = previous_node if child[:type] == :Background
        end
        lookup
      end
    end
  end
end
