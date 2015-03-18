require 'cucumber/running_test_case'
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'

module Cucumber
  describe RunningTestCase do
    include Core
    include Core::Gherkin::Writer

    attr_accessor :wrapped_test_case, :core_test_case

    before do
      receiver = double.as_null_object
      allow(receiver).to receive(:test_case) { |core_test_case|
        self.core_test_case = core_test_case
        self.wrapped_test_case = RunningTestCase.new(core_test_case)
      }
      compile [gherkin_doc], receiver
    end

    context "for a regular scenario" do
      let(:gherkin_doc) do
        gherkin do
          feature "feature name" do
            scenario "scenario name" do
              step "passing"
            end
          end
        end
      end

      it "sets the scenario name correctly" do
        expect(wrapped_test_case.name).to eq "scenario name"
      end

      it "sets the feature name correctly" do
        expect(wrapped_test_case.feature.name).to eq "feature name"
      end

      it "exposes properties of the test_case" do
        expect(wrapped_test_case.location).to eq core_test_case.location
        expect(wrapped_test_case.source).to eq core_test_case.source
        expect(wrapped_test_case.keyword).to eq core_test_case.keyword
      end
    end

    context "for a scenario outline" do
      let(:gherkin_doc) do
        gherkin do
          feature "feature name" do
            scenario_outline "scenario outline name" do
              step "passing with <arg1> <arg2>"

              examples "examples name" do
                row "arg1", "arg2"
                row "a", "b"
              end
            end
          end
        end
      end

      it "sets the test case's name correctly" do
        expect(wrapped_test_case.name).to eq "scenario outline name, examples name (#1)"
      end

      it "sets the feature name correctly" do
        expect(wrapped_test_case.feature.name).to eq "feature name"
      end

      it "exposes properties of the test_case" do
        expect(wrapped_test_case.location).to eq core_test_case.location
        expect(wrapped_test_case.source).to eq core_test_case.source
        expect(wrapped_test_case.keyword).to eq core_test_case.keyword
      end

      it "exposes the examples table row cell values" do
        expect(wrapped_test_case.cell_values).to eq ["a", "b"]
      end

    end
  end
end
