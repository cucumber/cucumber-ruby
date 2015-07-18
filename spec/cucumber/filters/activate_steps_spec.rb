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
  let(:filter) { Cucumber::Filters::ActivateSteps.new(step_definitions, configuration) }
  let(:configuration) { double(dry_run?: false) }

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
      compile [doc], receiver, [filter]
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
      compile [doc], receiver, [filter]
    end
  end

  context "undefined step" do
    let(:step_definitions) { double(find_match: nil) }

    let(:doc) do
      gherkin do
        feature do
          scenario do
            step 'an undefined step'
          end
        end
      end
    end

    it "does not activate the step" do
      expect(receiver).to receive(:test_case) do |test_case|
        expect(test_case.test_steps[0].execute).to be_undefined
      end
      compile [doc], receiver, [filter]
    end
  end

  context "dry run" do
    let(:configuration) { double(dry_run?: true) }

    let(:doc) do
      gherkin do
        feature do
          scenario do
            step 'a passing step'
          end
        end
      end
    end

    it "activates each step with a skipping action" do
      expect(receiver).to receive(:test_case) do |test_case|
        expect(test_case.test_steps[0].execute).to be_skipped
      end
      compile [doc], receiver, [filter]
    end
  end

  context "undefined step in a dry run" do
    let(:step_definitions) { double(find_match: nil) }
    let(:configuration) { double(dry_run?: true) }

    let(:doc) do
      gherkin do
        feature do
          scenario do
            step 'an undefined step'
          end
        end
      end
    end

    it "does not activate the step" do
      expect(receiver).to receive(:test_case) do |test_case|
        expect(test_case.test_steps[0].execute).to be_undefined
      end
      compile [doc], receiver, [filter]
    end
  end


end
