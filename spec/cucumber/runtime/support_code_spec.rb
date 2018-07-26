# frozen_string_literal: true

require 'spec_helper'

module Cucumber
  describe Runtime::SupportCode do
    let(:user_interface) { double('user interface') }
    subject { Runtime::SupportCode.new(user_interface, configuration) }
    let(:configuration) { Configuration.new(options) }
    let(:options) { {} }
    let(:dsl) do
      @rb = subject.ruby
      Object.new.extend(RbSupport::RbDsl)
    end

    describe '#apply_before_hooks' do
      let(:test_case) { double }
      let(:test_step) { double }

      it 'applies before hooks to test cases with steps' do
        allow(test_case).to receive(:test_steps).and_return([test_step])
        allow(test_case).to receive(:with_steps).and_return(double)

        expect(subject.apply_before_hooks(test_case)).not_to equal(test_case)
      end

      it 'does not apply before hooks to test cases with no steps' do
        allow(test_case).to receive(:test_steps).and_return([])

        expect(subject.apply_before_hooks(test_case)).to equal(test_case)
      end
    end

    describe '#apply_after_hooks' do
      let(:test_case) { double }
      let(:test_step) { double }

      it 'applies after hooks to test cases with steps' do
        allow(test_case).to receive(:test_steps).and_return([test_step])
        allow(test_case).to receive(:with_steps).and_return(double)

        expect(subject.apply_after_hooks(test_case)).not_to equal(test_case)
      end

      it 'does not apply after hooks to test cases with no steps' do
        allow(test_case).to receive(:test_steps).and_return([])

        expect(subject.apply_after_hooks(test_case)).to equal(test_case)
      end
    end
  end
end
