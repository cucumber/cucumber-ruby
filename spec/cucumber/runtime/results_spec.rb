require 'spec_helper'

module Cucumber
  describe Runtime::Results do

    let(:configuration)   {double 'Configuration', :strict? => false}
    let(:passed_scenario) {double 'Scenario', :status => :passed}
    let(:failed_scenario) {double 'Scenario', :status => :failed}
    let(:passed_step)     {double 'Step', :status => :passed}
    let(:failed_step)     {double 'Step', :status => :failed}
    let(:pending_step)    {double 'Step', :status => :pending}
    let(:undefined_step)  {double 'Step', :status => :undefined}

    subject {described_class.new(configuration)}

    describe '#failure?' do
      context 'feature is not work in progress' do
        before do
          allow(configuration).to receive(:wip?) { false }
        end

        it 'returns true if a scenario failed' do
          subject.scenario_visited(passed_scenario)
          subject.scenario_visited(failed_scenario)

          expect(subject).to be_failure
        end

        it 'returns true if a step failed' do
          subject.step_visited(failed_step)

          expect(subject).to be_failure
        end

        it 'returns false if there are no scenarios' do
          expect(subject).not_to be_failure
        end

        it 'returns false if all scenarios passed' do
          subject.scenario_visited(passed_scenario)
          subject.scenario_visited(passed_scenario)

          expect(subject).not_to be_failure
        end

        context 'configuration is strict' do
          before do
            allow(configuration).to receive(:strict?) { true }
          end

          it 'returns true if a step is pending' do
            subject.step_visited(pending_step)

            expect(subject).to be_failure
          end

          it 'returns true if a step is undefined' do
            subject.step_visited(undefined_step)

            expect(subject).to be_failure
          end
        end
      end

      context 'feature is work in progress' do
        before do
          allow(configuration).to receive(:wip?) { true }
        end

        it 'returns true if a scenario passed' do
          subject.scenario_visited(passed_scenario)

          expect(subject).to be_failure
        end

        it 'returns false if there are no scenarios' do
          expect(subject).not_to be_failure
        end

        it 'returns false if all scenarios fail' do
          subject.scenario_visited(failed_scenario)

          expect(subject).not_to be_failure
        end
      end
    end
  end
end
