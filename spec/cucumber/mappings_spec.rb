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
        gherkin_docs = [
          gherkin do
            feature 'test', tags: '@foo @bar' do
              scenario 'test', tags: '@baz' do
                step 'passing'
              end
            end
          end
        ]

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

        expect(scenario_spy.source_tag_names).to eq %w(@foo @bar @baz)
      end
    end
  end
end
