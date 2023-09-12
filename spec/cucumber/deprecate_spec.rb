# frozen_string_literal: true

require 'spec_helper'

module Cucumber
  module Deprecate
    describe 'Cucumber.deprecate' do
      it 'fails when running the tests' do
        expect do
          Cucumber.deprecate('Use some_method instead', 'someMethod', '1.0.0')
        end.to raise_exception('This method is due for removal after version 1.0.0')
      end

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
end
