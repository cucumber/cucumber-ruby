# frozen_string_literal: true

require 'spec_helper'

module Cucumber
  describe Runtime do
    subject { Runtime.new(options) }
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

    describe '#make_meta' do
      it 'generates a Meta message with platform information' do
        meta = subject.make_meta
        expect(meta.protocol_version).to match(/\d+\.\d+\.\d+/)
        expect(meta.implementation.name).to eq('cucumber-ruby')
        expect(meta.implementation.version).to eq(Cucumber::VERSION)
        expect(meta.runtime.name).to match(/(jruby|ruby)/)
        expect(meta.runtime.version).to eq(RUBY_VERSION)
        expect(meta.os.name).to match(/.+/)
        expect(meta.os.version).to match(/.+/)
        expect(meta.cpu.name).to match(/.+/)
      end
    end
  end
end
