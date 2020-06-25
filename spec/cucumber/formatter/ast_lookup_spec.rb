require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/ast_lookup'
require 'cucumber/cli/options'
require 'json'

module Cucumber
  module Formatter
    describe AstLookup do
      extend SpecHelperDsl
      include SpecHelper

      before(:each) do
        @out = StringIO.new
        @config = actual_runtime.configuration.with_options(out_stream: @out)
        @formatter = AstLookup.new(@config)

        @gherkin_documents = []
        @test_cases = []

        @config.on_event(:gherkin_source_parsed) do |event|
          @gherkin_documents << event.gherkin_document
        end

        @config.on_event(:test_case_created) do |event|
          @test_cases << event.test_case
        end

        run_defined_feature
      end

      describe 'gherkin_document(uri)' do
        @feature = <<-FEATURE
        Feature: some feature

        Scenario: a simple scenario
          Given a step
        FEATURE
        define_feature(@feature, 'path/to/the.feature')

        it 'returns nil when no document match' do
          expect(@formatter.gherkin_document('path/to/another.feature')).to be nil
        end

        it 'returns the matching Gherkin document' do
          expect(@formatter.gherkin_document('path/to/the.feature')).to eq(@gherkin_documents.first)
        end
      end

      context 'scenario_source(test_case)' do
        @feature = <<-FEATURE
        Feature: some feature

        Scenario: a simple scenario
          Given a step
        FEATURE

        define_feature(@feature, 'path/to/the.feature')

        it 'returns the scenario' do
          source = @formatter.scenario_source(@test_cases.first)

          expect(source.type).to eq(:Scenario)
          expect(source.scenario).to eq(@gherkin_documents.first.feature.children.first.scenario)
        end

        context 'when the scenario is scoped in a Rule' do
          @feature = <<-FEATURE
          Feature: some feature

            Rule: 1 - do not talk about this feature
              Scenario: a simple scenario
                Given a step
          FEATURE

          define_feature(@feature, 'path/to/the.feature')

          it 'returns the scenario' do
            source = @formatter.scenario_source(@test_cases.first)

            expect(source.type).to eq(:Scenario)
            expect(source.scenario).to eq(@gherkin_documents.first.feature.children.first.rule.children.first.scenario)
          end
        end

        context 'when the test case comes from a scenario + example' do
          @feature = <<-FEATURE
          Feature: some feature

          Scenario: with examples
            Given a <status> step

            Examples:
              | status |
              | passed |
              | failed |
          FEATURE

          define_feature(@feature, 'path/to/the.feature')

          it 'returns some extra information about the example used' do
            source = @formatter.scenario_source(@test_cases.last)

            expect(source.type).to eq(:ScenarioOutline)
            expect(source.scenario_outline).to eq(@gherkin_documents.first.feature.children.last.scenario)
            expect(source.examples).to eq(@gherkin_documents.first.feature.children.last.scenario.examples.first)
            expect(source.row).to eq(@gherkin_documents.first.feature.children.last.scenario.examples.first.table_body.last)
          end
        end
      end

      context 'step_source(test_step)' do
        @feature = <<-FEATURE
        Feature: some feature

        Scenario: a simple scenario
          Given a step
        FEATURE

        define_feature(@feature, 'path/to/the.feature')

        it 'returns the step' do
          source = @formatter.step_source(@test_cases.first.test_steps.first)

          expect(source.type).to eq(:Step)
          expect(source.step).to eq(@gherkin_documents.first.feature.children.first.scenario.steps.first)
        end

        context 'when a background is defined' do
          @feature = <<-FEATURE
          Feature: some feature
            Background:
              Given things are done before

            Scenario: a simple scenario
              Given a step
          FEATURE
          define_feature(@feature, 'path/to/the.feature')

          it 'can find Before Hooks' do
            source = @formatter.step_source(@test_cases.first.test_steps.first)
            expect(source.type).to eq(:Step)
            expect(source.step).to eq(@gherkin_documents.first.feature.children.first.background.steps.first)
          end
        end
      end

      context 'snippet_step_keyword(test_step)' do
        @feature = <<-FEATURE
        Feature: some feature

        Scenario: a simple scenario
          Given a step
          When another step
          And a third step
        FEATURE
        define_feature(@feature, 'path/to/the.feature')

        it 'returns the keyword for the snippet' do
          keyword = @formatter.snippet_step_keyword(@test_cases.first.test_steps.last)

          expect(keyword).to eq('When')
        end

        context 'when no keywords where defined at all' do
          @feature = <<-FEATURE
          Feature: some feature

          Scenario: a simple scenario
            * a step
          FEATURE
          define_feature(@feature, 'path/to/the.feature')

          it 'returns the keyword for the snippet' do
            keyword = @formatter.snippet_step_keyword(@test_cases.first.test_steps.last)

            expect(keyword).to eq('Given')
          end
        end

        context 'when the keyword comes from the background' do
          @feature = <<-FEATURE
          Feature: some feature

          Background:
            When a situation

          Scenario: a simple scenario
            And a step
          FEATURE
          define_feature(@feature, 'path/to/the.feature')

          it 'returns the keyword for the snippet' do
            keyword = @formatter.snippet_step_keyword(@test_cases.first.test_steps.last)

            expect(keyword).to eq('When')
          end

          context 'which is in a Rule' do
            @feature = <<-FEATURE
            Feature: some feature

            Background:
              When a situation

            Rule: there is some extra context
              Background:
                Then something else

              Scenario: a simple scenario
                And a step
            FEATURE
            define_feature(@feature, 'path/to/the.feature')

            it 'returns the keyword for the snippet' do
              keyword = @formatter.snippet_step_keyword(@test_cases.first.test_steps.last)

              expect(keyword).to eq('Then')
            end
          end
        end

        context 'when using another language than english' do
          @feature = <<-FEATURE
          #language: fr
          Fonctionnalité: une fonctionnalité

          Scénario: un scénario simple
            Soit une étape
            Quand une autre étape
            Et une troisième étape
          FEATURE
          define_feature(@feature, 'path/to/the.feature')

          it 'returns the translated keyword for the snippet' do
            keyword = @formatter.snippet_step_keyword(@test_cases.first.test_steps.last)

            expect(keyword).to eq('Quand')
          end
        end
      end
    end
  end
end
