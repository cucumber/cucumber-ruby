# frozen_string_literal: true

require_relative '../../support/cck/examples'

describe CCK::Examples do
  let(:features_path) { File.expand_path("#{File.dirname(__FILE__)}/../../features") }

  describe '#supporting_code_for' do
    context 'with an example that exists' do
      it 'returns the path of the folder containing the supporting code for the example' do
        expect(described_class.supporting_code_for('hooks')).to eq("#{features_path}/hooks")
      end
    end

    context 'with an example that does not exist' do
      it 'raises ArgumentError' do
        expect { described_class.supporting_code_for('nonexistent-example') }.to raise_error(ArgumentError)
      end
    end
  end
end
