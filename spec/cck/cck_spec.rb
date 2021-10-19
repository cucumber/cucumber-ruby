require 'cucumber-compatibility-kit'

describe 'Cucumber Compatibility Kit', cck: true do
  let(:cucumber_bin) { './bin/cucumber' }
  let(:cucumber_common_args) { '--publish-quiet --profile none --format message' }
  let(:cucumber_command) { "#{cucumber_bin} #{cucumber_common_args}" }

  examples = Cucumber::CompatibilityKit.gherkin_examples.reject { |example| example == 'retry' }

  examples.each do |example_name|
    describe "'#{example_name}' example" do
      include_examples 'cucumber compatibility kit' do
        let(:example) { example_name }
        let(:messages) { `#{cucumber_command} --require #{example_path} #{example_path}` }
      end
    end
  end
end
