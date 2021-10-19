require 'cucumber-compatibility-kit'

module KeysCheckerExtensions
  def compare(found, expected)
    errors = []

    found_keys = found.to_h(reject_nil_values: true).keys
    expected_keys = expected.to_h(reject_nil_values: true).keys

    return errors if found_keys.sort == expected_keys.sort

    missing_keys = (expected_keys - found_keys)

    extra_keys = (found_keys - expected_keys).reject { |key| ENV['CI'] && found.class == Cucumber::Messages::Meta && key ==  :ci }

    errors << "Found extra keys in message #{found.class.name}: #{extra_keys}" unless extra_keys.empty?
    errors << "Missing keys in message #{found.class.name}: #{missing_keys}" unless missing_keys.empty?
    errors
  rescue StandardError => e
    puts "found: #{found.inspect}"
    puts "expected: #{expected.inspect}"
    [e.message]
  end
end

class CCK::KeysChecker
  prepend KeysCheckerExtensions
end

module MessagesComparatorExtensions
  def compare_message(found, expected)
    return unless found.is_a?(Cucumber::Messages::Message)
    return if found.is_a?(Cucumber::Messages::Ci) && expected.nil?
    super(found, expected)
  end
end

class CCK::MessagesComparator
  prepend MessagesComparatorExtensions
end

describe 'Cucumber Compatibility Kit', cck: true do
  let(:cucumber_bin) { './bin/cucumber' }
  let(:cucumber_common_args) { '--publish-quiet --profile none --format message' }
  let(:cucumber_command) { "bundle exec #{cucumber_bin} #{cucumber_common_args}" }

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
