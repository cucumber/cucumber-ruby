require 'spec_helper'

module Cucumber
  describe Runtime do
    subject { Runtime.new(options) }
    let(:options) { {} }

    describe "#features_paths" do
      let(:options) { {:paths => ['foo/bar/baz.feature', 'foo/bar/features/baz.feature', 'other_features'] } }

      it "returns the value from configuration.paths" do
        expect(subject.features_paths).to eq options[:paths]
      end
    end

    describe "#configure" do
      let(:support_code)      { double(Runtime::SupportCode).as_null_object }
      let(:new_configuration) { double('New configuration')}

      before(:each) do
        allow(Runtime::SupportCode).to receive(:new) { support_code }
      end

      it "tells the support_code about the new configuration" do
        expect(support_code).to receive(:configure).with(new_configuration)
        subject.configure(new_configuration)
      end

      it "replaces the existing configuration" do
        # not really sure how to test this. Maybe we should just expose
        # Runtime#configuration with an attr_reader?
        some_new_paths = ['foo/bar', 'baz']

        allow(new_configuration).to receive(:paths) { some_new_paths }

        subject.configure(new_configuration)

        expect(subject.features_paths).to eq some_new_paths
      end

      it '#doc_string' do
        expect(subject.doc_string('Text')).to eq 'Text'
      end
    end
  end
end
