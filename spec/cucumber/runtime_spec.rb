# frozen_string_literal: true

require 'spec_helper'

module Cucumber
  describe Runtime do
    subject { described_class.new(options) }
    let(:options) { {} }

    describe '#features_paths' do
      let(:options) { { paths: ['foo/bar/baz.feature', 'foo/bar/features/baz.feature', 'other_features'] } }

      it 'returns the value from configuration.paths' do
        expect(subject.features_paths).to eq options[:paths]
      end
    end

    describe '#doc_string' do
      it 'is creates an object equal to a string' do
        expect(subject.doc_string('Text')).to eq 'Text'
      end
    end
  end
end
