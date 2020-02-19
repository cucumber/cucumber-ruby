# frozen_string_literal: true

require 'spec_helper'

module Cucumber::Deprecate
  describe CliOption do
    let(:subject) { Cucumber::Deprecate::CliOption }
    let(:error_stream) { double }

    context '.deprecate' do
      it 'outputs a warning to the provided channel' do
        allow(error_stream).to receive(:puts)
        subject.deprecate(error_stream, '--some-option', 'Please use --another-option instead', '1.2.3')

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
