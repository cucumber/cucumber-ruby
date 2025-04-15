# frozen_string_literal: true

require 'spec_helper'

module Cucumber
  describe '.deprecate' do
    it 'outputs a message to $stderr' do
      allow($stderr).to receive(:puts)

      Cucumber.deprecate('Use #some_other_method instead', '#some_method', '1.0.0')
      expect($stderr).to have_received(:puts).with(
        a_string_including(
          'WARNING: #some_method is deprecated and will be removed after version 1.0.0. Use #some_other_method instead.'
        )
      )
    end
  end
end
