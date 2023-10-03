# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/runtime/meta_message_builder'

describe Cucumber::Runtime::MetaMessageBuilder do
  describe '.build_meta_message' do
    subject { described_class.build_meta_message }

    it { is_expected.to be_a(Cucumber::Messages::Meta) }

    it 'has a protocol version' do
      expect(subject.protocol_version).to eq(Cucumber::Messages::VERSION)
    end

    it 'has an implementation name' do
      expect(subject.implementation.name).to eq('cucumber-ruby')
    end

    it 'has an implementation version' do
      expect(subject.implementation.version).to eq(Cucumber::VERSION)
    end

    it 'has a runtime name' do
      expect(subject.runtime.name).to eq(RUBY_ENGINE)
    end

    it 'has a runtime version' do
      expect(subject.runtime.version).to eq(RUBY_VERSION)
    end

    it 'has an os name' do
      expect(subject.os.name).to eq(RbConfig::CONFIG['target_os'])
    end

    it 'has an os version' do
      expect(subject.os.version).to eq(Sys::Uname.uname.version)
    end

    it 'has a cpu name' do
      expect(subject.cpu.name).to eq(RbConfig::CONFIG['target_cpu'])
    end

    context 'with an overridden ENV hash' do
      subject { described_class.build_meta_message(env) }

      let(:env) { {} }

      it 'detects CI environment using the given env' do
        expect(Cucumber::CiEnvironment).to receive(:detect_ci_environment).with(env)

        subject
      end
    end

    context 'when running on a CI system without git data' do
      subject { described_class.build_meta_message.ci }

      before { expect(Cucumber::CiEnvironment).to receive(:detect_ci_environment).and_return(ci_data) }

      let(:ci_data) do
        {
          name: 'Jenkins',
          url: 'http://localhost:8080',
          buildNumber: '123'
        }
      end

      it { is_expected.to be_a(Cucumber::Messages::Ci) }

      it 'has a populated CI name from the ci input hash' do
        expect(subject.name).to eq(ci_data[:name])
      end

      it 'has a populated CI url from the ci input hash' do
        expect(subject.url).to eq(ci_data[:url])
      end

      it 'has a populated CI build number from the ci input hash' do
        expect(subject.build_number).to eq(ci_data[:buildNumber])
      end
    end

    context 'when running on a CI system with git data' do
      subject { described_class.build_meta_message.ci.git }

      before { expect(Cucumber::CiEnvironment).to receive(:detect_ci_environment).and_return(ci_data) }

      let(:ci_data) do
        {
          git: {
            remote: 'origin',
            revision: '1234567890',
            branch: 'main',
            tag: 'v1.0.0'
          }
        }
      end

      it { is_expected.to be_a(Cucumber::Messages::Git) }

      it 'has a populated git remote from the git field of the ci input hash' do
        expect(subject.remote).to eq(ci_data[:git][:remote])
      end

      it 'has a populated git revision from the git field of the ci input hash' do
        expect(subject.revision).to eq(ci_data[:git][:revision])
      end

      it 'has a populated git branch from the git field of the ci input hash' do
        expect(subject.branch).to eq(ci_data[:git][:branch])
      end

      it 'has a populated git tag from the git field of the ci input hash' do
        expect(subject.tag).to eq(ci_data[:git][:tag])
      end
    end

    context 'when not running on a CI system' do
      subject { described_class.build_meta_message.ci }

      before { expect(Cucumber::CiEnvironment).to receive(:detect_ci_environment).and_return(ci_data) }

      let(:ci_data) { nil }

      it { is_expected.to be_nil }
    end
  end
end
