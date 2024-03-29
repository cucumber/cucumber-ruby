# frozen_string_literal: true

require 'cucumber/filters/activate_steps'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core'

describe Cucumber::Filters::ActivateSteps do
  include Cucumber::Core::Gherkin::Writer
  include Cucumber::Core

  let(:step_match) { double(activate: activated_test_step) }
  let(:activated_test_step) { double }
  let(:receiver) { double.as_null_object }
  let(:filter) { described_class.new(step_match_search, configuration) }
  let(:step_match_search) { proc { [step_match] } }
  let(:configuration) { double(dry_run?: false, notify: nil) }

  context 'with a scenario containing a single step' do
    let(:doc) do
      gherkin do
        feature do
          scenario do
            step 'a passing step'
          end
        end
      end
    end

    it 'activates each step' do
      allow(step_match).to receive(:activate) do |test_step|
        expect(test_step.text).to eq('a passing step')
      end

      compile([doc], receiver, [filter])
    end

    it 'notifies with a StepActivated event' do
      allow(configuration).to receive(:notify) do |message, _test_step, _step_match|
        expect(message).to eq(:step_activated)
      end

      compile([doc], receiver, [filter])
    end

    it 'notifies with the correct step' do
      allow(configuration).to receive(:notify) do |_message, test_step, _step_match|
        expect(test_step.text).to eq('a passing step')
      end

      compile([doc], receiver, [filter])
    end
  end

  context 'with a scenario outline' do
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

    it 'activates each step' do
      allow(step_match).to receive(:activate) do |test_step|
        expect(test_step.text).to eq('a passing step')
      end

      compile([doc], receiver, [filter])
    end
  end

  context 'with an undefined step' do
    let(:step_match_search) { proc { [] } }

    let(:doc) do
      gherkin do
        feature do
          scenario do
            step 'an undefined step'
          end
        end
      end
    end

    it 'does not activate the step' do
      allow(receiver).to receive(:test_case) do |test_case|
        expect(test_case.test_steps[0].execute).to be_undefined
      end

      compile([doc], receiver, [filter])
    end

    it 'does not notify' do
      expect(configuration).not_to receive(:notify)

      compile([doc], receiver, [filter])
    end
  end

  context 'when using dry run' do
    let(:configuration) { double(dry_run?: true, notify: nil) }

    let(:doc) do
      gherkin do
        feature do
          scenario do
            step 'a passing step'
          end
        end
      end
    end

    it 'activates each step with a skipping action' do
      allow(receiver).to receive(:test_case) do |test_case|
        expect(test_case.test_steps[0].execute).to be_skipped
      end

      compile([doc], receiver, [filter])
    end

    it 'notifies with a StepActivated event' do
      allow(configuration).to receive(:notify) do |message, _test_step, _step_match|
        expect(message).to eq(:step_activated)
      end

      compile([doc], receiver, [filter])
    end

    it 'notifies with the correct step' do
      allow(configuration).to receive(:notify) do |_message, test_step, _step_match|
        expect(test_step.text).to eq('a passing step')
      end

      compile([doc], receiver, [filter])
    end
  end

  context 'with an undefined step in a dry run' do
    let(:step_match_search) { proc { [] } }
    let(:configuration) { double(dry_run?: true, notify: nil) }

    let(:doc) do
      gherkin do
        feature do
          scenario do
            step 'an undefined step'
          end
        end
      end
    end

    it 'does not activate the step' do
      allow(receiver).to receive(:test_case) do |test_case|
        expect(test_case.test_steps[0].execute).to be_undefined
      end

      compile([doc], receiver, [filter])
    end

    it 'does not notify' do
      expect(configuration).not_to receive(:notify)

      compile([doc], receiver, [filter])
    end
  end
end
