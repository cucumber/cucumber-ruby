require 'spec_helper'

module Cucumber
  describe Runtime::Results do

    let(:configuration) {double 'Configuration', :strict? => false}
    let(:passed_scenario) {double 'Scenario', :status => :passed}
    let(:failed_scenario) {double 'Scenario', :status => :failed}
    let(:passed_step) {double 'Step', :status => :passed}
    let(:failed_step) {double 'Step', :status => :failed}
    let(:pending_step) {double 'Step', :status => :pending}
    let(:undefined_step) {double 'Step', :status => :undefined}

    subject {described_class.new(configuration)}

    describe '#failure?' do
      context 'feature is not work in progress' do
        before do
          configuration.stub(:wip? => false)
        end

        it 'should return true if a scenario failed' do
          subject.scenario_visited(passed_scenario)
          subject.scenario_visited(failed_scenario)
          subject.should be_failure
        end

        it 'should return true if a step failed' do
          subject.step_visited(failed_step)
          subject.should be_failure
        end

        it 'should return false if there are no scenarios' do
          subject.should_not be_failure
        end

        it 'should return false if all scenarios passed' do
          subject.scenario_visited(passed_scenario)
          subject.scenario_visited(passed_scenario)
          subject.should_not be_failure
        end

        context 'configuration is strict' do
          before do
            configuration.stub(:strict? => true)
          end

          it 'should return true if a step is pending' do
            subject.step_visited(pending_step)
            subject.should be_failure
          end

          it 'should return true if a step is undefined' do
            subject.step_visited(undefined_step)
            subject.should be_failure
          end
        end
      end

      context 'feature is work in progress' do
        before do
          configuration.stub(:wip? => true)
        end

        it 'should return true if a scenario passed' do
          subject.scenario_visited(passed_scenario)
          subject.should be_failure
        end

        it 'should return false if there are no scenarios' do
          subject.should_not be_failure
        end

        it 'should return false if all scenarios fail' do
          subject.scenario_visited(failed_scenario)
          subject.should_not be_failure
        end
      end
    end
  end
end
