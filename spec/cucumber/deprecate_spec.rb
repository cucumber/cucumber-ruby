# frozen_string_literal: true

require 'spec_helper'

module Cucumber
  describe '.deprecate' do
    it 'outputs a message to $stderr' do
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
