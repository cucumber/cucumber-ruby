# frozen_string_literal: true

module Cucumber
  describe '.deprecate' do
    it 'outputs a message to $stderr' do
      allow(Kernel).to receive(:warn)

      Cucumber.deprecate('Use #some_other_method instead', '#some_method', '1.0.0')
      expect(Kernel).to have_received(:warn).with(
        a_string_including(
          'WARNING: #some_method is deprecated and will be removed after version 1.0.0. Use #some_other_method instead.'
        )
      )
    end
  end
end
