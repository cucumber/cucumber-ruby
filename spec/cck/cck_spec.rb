# frozen_string_literal: true

require 'cucumber-compatibility-kit'

describe 'Cucumber Compatibility Kit', cck: true do
  let(:cucumber_bin) { 'cucumber' }
  let(:cucumber_common_args) { '--publish-quiet --profile none --format message' }
  let(:cucumber_command) { "bundle exec #{cucumber_bin} #{cucumber_common_args}" }

  Cucumber::CompatibilityKit.gherkin_examples.each do |example_name|
    describe "'#{example_name}' example" do
      include_examples 'cucumber compatibility kit' do
        let(:example) { example_name }
        let(:extra_args) { example == 'retry' ? '--retry 2' : '' }
        let(:messages) { `#{cucumber_command} #{extra_args} --require #{example_path} #{example_path}` }
      end
    end
  end
end
