# frozen_string_literal: true

require_relative 'support/shared_examples'
require_relative 'support/cck/examples'

require 'cck/examples'

describe 'Cucumber Compatibility Kit', type: :feature, cck: true do
  let(:cucumber_command) { 'bundle exec cucumber --publish-quiet --profile none --format message' }

  ['attachments'].each do |example_name|
    describe "'#{example_name}' example" do
      include_examples 'cucumber compatibility kit' do
        let(:example) { example_name }
        let(:extra_args) { example == 'retry' ? '--retry 2' : '' }
        let(:support_code_path) { CCK::Examples.supporting_code_for(example) }
        let(:messages) { `#{cucumber_command} #{extra_args} --require #{support_code_path} #{cck_path}` }
      end
    end
  end
end
