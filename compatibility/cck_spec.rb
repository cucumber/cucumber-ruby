# frozen_string_literal: true

require_relative 'support/shared_examples'
require_relative 'support/cck/compatibility_kit'

describe 'Cucumber Compatibility Kit', cck: true do
  let(:cucumber_command) { 'bundle exec cucumber --publish-quiet --profile none --format message' }

  CCK::CompatibilityKit.gherkin_examples.each do |example_name|
    describe "'#{example_name}' example" do
      include_examples 'cucumber compatibility kit' do
        let(:example) { example_name }
        let(:extra_args) { example == 'retry' ? '--retry 2' : '' }
        let(:messages) { `#{cucumber_command} #{extra_args} --require #{cck_implementation_path} #{cck_implementation_path}` }
      end
    end
  end
end
