require 'cucumber/filters/activate_steps'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core'

describe Cucumber::Filters::ActivateSteps do
  include Cucumber::Core::Gherkin::Writer
  include Cucumber::Core

  let(:step_definitions) { double(find_match: step_match) }
  let(:step_match) { double(activate: activated_test_step) }
  let(:activated_test_step) { double }
  let(:receiver) { double.as_null_object }

  context "a scenario with a single step" do
    let(:doc) do
      gherkin do
        feature do
          scenario do
            step 'a passing step'
          end
        end
      end
    end

    it "activates each step" do
      expect(step_match).to receive(:activate) do |test_step|
        expect(test_step.name).to eq 'a passing step'
      end
      compile [doc], receiver, [Cucumber::Filters::ActivateSteps.new(step_definitions)]
    end
  end

  context "a scenario outline" do
    let(:doc) do
      gherkin do
        feature do
          scenario_outline do
            step 'a <status> step'

            examples do
              row 'status'
              row 'passing'
            end
          end
        end
      end
    end

    it "activates each step" do
      expect(step_match).to receive(:activate) do |test_step|
        expect(test_step.name).to eq 'a passing step'
      end
      compile [doc], receiver, [Cucumber::Filters::ActivateSteps.new(step_definitions)]
    end
  end

end
