require_relative '../../shared_examples.rb'

describe __dir__ do
  let(:current_path) { __dir__ }
  let(:monorepo_path) { ENV['MONOREPO_PATH'] || '../../../cucumber' }
  let(:examples_name) { File.basename(current_path) }

  let(:generated) { "#{current_path}/#{examples_name}.ndjson" }
  let(:original) { "#{monorepo_path}/compatibility-kit/javascript/features/#{examples_name}/#{examples_name}.ndjson" }

  include_examples 'equivalent messages'
end
