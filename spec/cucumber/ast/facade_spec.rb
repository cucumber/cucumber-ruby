require 'cucumber/ast/facade'
require 'cucumber/core/gherkin/writer'

module Cucumber::Ast
  describe Facade do
    include Cucumber::Core::Gherkin::Writer
    include Cucumber::Core

    attr_accessor :wrapped_test_case, :core_test_case

    before do
      receiver = double.as_null_object
      allow(receiver).to receive(:test_case) { |core_test_case|
        self.core_test_case = core_test_case
        self.wrapped_test_case = Facade.new(core_test_case).build_scenario
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
              step "passing with <arg>"

              examples "examples name" do
                row "arg"
                row "a"
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

    end
  end
end
