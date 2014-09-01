require_relative "../../lib/cucumber/mappings"
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'

module Cucumber
  class Mappings
    describe Scenario do
      include Core::Gherkin::Writer
      include Core
      let(:ruby)      { double.as_null_object }
      let(:runtime)   do
        double(
          load_programming_language: ruby,
          step_match: double
        )
      end
      let(:mappings)  { Mappings.new(runtime) }
      let(:report)    { double.as_null_object }

      it "responds to #source_tag_names" do
        define_gherkin do
          feature 'test', tags: '@foo @bar' do
            scenario 'test', tags: '@baz' do
              step 'passing'
            end
          end
        end

        before do |scenario|
          expect(scenario.source_tag_names).to eq %w(@foo @bar @baz)
        end
      end

      describe "#scenario_outline" do

        it "throws a NoMethodError when the test case is from a scenario" do
          define_gherkin do
            feature do
              scenario do
                step 'passing'
              end
            end
          end

          before do |test_case|
            expect{ test_case.scenario_outline }.to raise_error(NoMethodError)
          end
        end

        it "points to self when the test case is from a scenario outline" do
          define_gherkin do
            feature do
              scenario_outline 'outline' do
                step 'passing'

                examples 'examples' do
                  row 'a'
                  row '1'
                end
              end
            end
          end

          before do |test_case|
            expect(test_case.scenario_outline).to_not be_nil
            expect(test_case.scenario_outline.name).to eq "Scenario Outline: outline, examples (row 1)"
          end
        end

      end

      describe "#outline?" do

        it "returns false when the test case is from a scenario" do
          define_gherkin do
            feature do
              scenario do
                step 'passing'
              end
            end
          end

          before do |test_case|
            expect(test_case).to_not be_an_outline
          end
        end

        it "returns true when the test case is from a scenario" do
          define_gherkin do
            feature do
              scenario_outline do
                step 'passing'

                examples 'examples' do
                  row 'a'
                  row '1'
                end
              end
            end
          end

          before do |test_case|
            expect(test_case).to be_an_outline
          end
        end

      end
      attr_accessor :gherkin_docs

      def define_gherkin(&block)
        self.gherkin_docs = [gherkin(&block)]
      end

      def before
        # TODO: the complexity of this stubbing shows we need to clean up the interface
        scenario_spy = nil
        allow(ruby).to receive(:hooks_for) do |phase, scenario|
          if phase == :before
            hook = double
            expect(hook).to receive(:invoke) do |phase, scenario|
              scenario_spy = scenario
            end
            [hook]
          else
            []
          end
        end
        execute gherkin_docs, mappings, report
        yield scenario_spy
      end
    end
  end
end
