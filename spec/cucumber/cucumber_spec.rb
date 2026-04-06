# frozen_string_literal: true

RSpec.describe Cucumber do
  describe '.deprecate' do
    it 'outputs a message to $stderr' do
      allow(Kernel).to receive(:warn)

      expect(Kernel).to receive(:warn).with(
        a_string_including('WARNING: #some_method is deprecated and will be removed after version 1.0.0. Use #some_other_method instead.')
      )

      described_class.deprecate('Use #some_other_method instead', '#some_method', '1.0.0')
    end
  end

  describe '.logger' do
    it 'generates a new logger if current logger is nil' do
      described_class.logger = nil
      logger = described_class.logger

      expect(logger).to be_instance_of Logger
    end
  end
end
