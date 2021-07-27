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

    describe '#install_wire_plugin' do
      it 'informs the user it is deprecated' do
        stub_const('Cucumber::Deprecate::STRATEGY', Cucumber::Deprecate::ForUsers)
        allow(STDERR).to receive(:puts)
        allow_any_instance_of(Configuration).to receive(:all_files_to_load).and_return(['file.wire'])

        begin
          subject.run!
        rescue NoMethodError
          # this is actually expected
        end

        expect(STDERR).to have_received(:puts).with(
          a_string_including([
            'WARNING: # built-in usage of the wire protocol is deprecated and will be removed after version 9.0.0.',
            'See https://github.com/cucumber/cucumber-ruby-wire#migration-from-built-in-to-plugin for more info.'
          ].join(' '))
        )
      end
    end
  end
end
