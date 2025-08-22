# frozen_string_literal: true

describe Cucumber do
  describe '.deprecate' do
    it 'outputs a message to $stderr' do
      allow(Kernel).to receive(:warn)

      expect(Kernel).to receive(:warn).with(
        a_string_including('WARNING: #some_method is deprecated and will be removed after version 1.0.0. Use #some_other_method instead.')
      )

      described_class.deprecate('Use #some_other_method instead', '#some_method', '1.0.0')
    end
  end
end
