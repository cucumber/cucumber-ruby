# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/rake/forked_cucumber_runner'
require 'rake'

RSpec.describe Cucumber::Rake::ForkedCucumberRunner do
  let(:libs) { ['lib'] }
  let(:binary) { Cucumber::BINARY }
  let(:cucumber_opts) { ['--cuke-option'] }
  let(:feature_files) { ['./some.feature'] }

  context 'when running with bundler' do
    subject { described_class.new(libs, binary, cucumber_opts, bundler, feature_files) }

    let(:bundler) { true }

    it 'does use bundler if bundler is set to true' do
      expect(subject.use_bundler).to be true
    end

    it 'uses bundle exec to find cucumber and libraries' do
      expect(subject.cmd).to eq [
        Cucumber::RUBY_BINARY,
        '-S',
        'bundle',
        'exec',
        'cucumber',
        '--cuke-option'
      ] + feature_files
    end
  end

  context 'when running without bundler' do
    subject { described_class.new(libs, binary, cucumber_opts, bundler, feature_files) }

    let(:bundler) { false }

    it 'does not use bundler if bundler is set to false' do
      expect(subject.use_bundler).to be false
    end

    it 'uses well known cucumber location and specified libraries' do
      expect(subject.cmd).to eq [
        Cucumber::RUBY_BINARY,
        '-I',
        '"lib"',
        "\"#{Cucumber::BINARY}\"",
        '--cuke-option'
      ] + feature_files
    end
  end
end
