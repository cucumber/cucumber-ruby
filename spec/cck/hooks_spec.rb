require 'cucumber-compatibility-kit'

describe 'cck/hooks' do
  let(:cck_path) { Cucumber::CompatibilityKit.getExamplePath('hooks') }
  let(:original) { 'hooks' }
  # let(:original) { '../../cucumber/compatibility-kit/javascript/features/hooks/hooks.feature.ndjson' }
  let(:generated) do
    `./bin/cucumber --publish-quiet --profile none --require #{cck_path} #{cck_path} -f message -o tmp/hooksss.ndjson`

    'tmp/hooksss.ndjson'
  end

  include_examples 'equivalent messages'
end