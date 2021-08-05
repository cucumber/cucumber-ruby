# frozen_string_literal: true

require 'spec_helper'

module Cucumber::Deprecate
  describe 'Cucumber.deprecate' do
    context 'for developers' do
      it 'fails when running the tests' do
        expect do
          Cucumber.deprecate('Use some_method instead', 'someMethod', '1.0.0')
        end.to raise_exception('This method is due for removal after version 1.0.0')
      end
    end

    context 'for users' do
      it 'outputs a message to STDERR' do
        stub_const('Cucumber::Deprecate::STRATEGY', ForUsers)
        allow($stderr).to receive(:puts)

        Cucumber.deprecate('Use some_method instead', 'someMethod', '1.0.0')
        expect($stderr).to have_received(:puts).with(
          a_string_including(
            'WARNING: #someMethod is deprecated and will be removed after version 1.0.0. Use some_method instead.'
          )
        )
      end
    end
  end

  describe CliOption do
    let(:error_stream) { double }

    context '.deprecate' do
      it 'outputs a warning to the provided channel' do
        allow(error_stream).to receive(:puts)
        described_class.deprecate(error_stream, '--some-option', 'Please use --another-option instead', '1.2.3')

        expect(error_stream).to have_received(:puts).with(
          a_string_including(
            "WARNING: --some-option is deprecated and will be removed after version 1.2.3.\n" \
            'Please use --another-option instead.'
          )
        )
      end
    end
  end
end
