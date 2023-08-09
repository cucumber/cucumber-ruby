# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/runtime/meta_message_builder'

describe Cucumber::Runtime::MetaMessageBuilder do
  describe 'self#build_meta_message' do
    subject { Cucumber::Runtime::MetaMessageBuilder.build_meta_message }

    it { is_expected.to be_a(Cucumber::Messages::Meta) }

    it 'fills system info in the meta message' do
      expect(subject.protocol_version).to eq(Cucumber::Messages::VERSION)
      expect(subject.implementation.name).to eq('cucumber-ruby')
      expect(subject.implementation.version).to eq(Cucumber::VERSION)
      expect(subject.runtime.name).to eq(RUBY_ENGINE)
      expect(subject.runtime.version).to eq(RUBY_VERSION)
      expect(subject.os.name).to eq(RbConfig::CONFIG['target_os'])
      expect(subject.os.version).to eq(Sys::Uname.uname.version)
      expect(subject.cpu.name).to eq(RbConfig::CONFIG['target_cpu'])
    end

    context 'with overriden ENV' do
      subject { Cucumber::Runtime::MetaMessageBuilder.build_meta_message(env) }
      let(:env) { {} }

      it 'detects CI environment using the given env' do
        expect(Cucumber::CiEnvironment).to receive(:detect_ci_environment).with(env)
        subject
      end
    end

    describe ':ci' do
      subject { Cucumber::Runtime::MetaMessageBuilder.build_meta_message.ci }

      before do
        expect(Cucumber::CiEnvironment).to receive(:detect_ci_environment).and_return(ci_data)
      end

      context 'when running on a CI system' do
        let(:ci_data) do
          {
            name: 'Jenkins',
            url: 'http://localhost:8080',
            buildNumber: '123'
          }
        end

        it { is_expected.to be_a(Cucumber::Messages::Ci) }

        it 'fills ci data in the :ci field' do
          expect(subject.name).to eq(ci_data[:name])
          expect(subject.url).to eq(ci_data[:url])
          expect(subject.build_number).to eq(ci_data[:buildNumber])
        end

        describe ':git field' do
          subject { Cucumber::Runtime::MetaMessageBuilder.build_meta_message.ci.git }

          context 'with some git data' do
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

            it 'fills the git data in the :git field' do
              expect(subject.remote).to eq(ci_data[:git][:remote])
              expect(subject.revision).to eq(ci_data[:git][:revision])
              expect(subject.branch).to eq(ci_data[:git][:branch])
              expect(subject.tag).to eq(ci_data[:git][:tag])
            end
          end

          context 'without git data' do
            it { is_expected.to be_nil }
          end
        end
      end

      context 'when not running on a CI system' do
        let(:ci_data) { nil }

        it { is_expected.to be_nil }
      end
    end
  end
end
