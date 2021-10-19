require 'cucumber-compatibility-kit'

module KeysCheckerExtensions
  def compare(found, expected)
    super(found, expected)
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
