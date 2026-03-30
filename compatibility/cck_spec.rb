# frozen_string_literal: true

require_relative 'support/shared_examples'
require_relative 'support/compatibility_kit'

require 'cucumber/compatibility_kit'

# This is the implementation of the CCK testing for cucumber-ruby
# It will run each example from the CCK that is of type "gherkin" (As "markdown" examples aren't implemented in ruby)
#
# All step definition and required supporting logic is contained here, the CCK gem proper contains the source of truth
# of the "golden" NDJSON files and attachments / miscellaneous files
describe CCK, :cck do
  let(:cucumber_command) { 'bundle exec cucumber --publish-quiet --profile none --format message' }

  # CCK v22 conformance
  # OVERALL: 93 examples, 5 failures, 88 passed
  # SANITIZED: 84 examples, 0 failures, 84 passed

  # Global Hooks Before All -> 0 messages generated - Expected 22
  # Global Hooks Attachments -> 0 messages generated - Expected 20
  # Global Hooks After All -> 17 messages generated - Expected 27 (Missing 5 testRunHookStarted + 5 testRunHookFinished)

  # There are a variety of non-conformancies in the CCK currently with reasons for them to be fixed
  # -> global-hooks-beforeall-error: This requires an internal change to cucumber to make it store all hook messages before exiting
  # -> global-hooks-afterall-error: This requires an internal change to cucumber to make it store all hook messages before exiting
  # -> global-hooks-attachments: This requires a change to cucumber to allow the `attach` method to be called in the BeforeAll/AfterAll hooks

  items_to_fix =
    %w[
      global-hooks-afterall-error
      global-hooks-attachments
      global-hooks-beforeall-error
    ]
  _failing, passing = CompatibilityKit.gherkin.partition { |name| items_to_fix.include?(name) }

  passing.each do |example_name|
    describe "'#{example_name}' example" do
      include_examples 'cucumber compatibility kit' do
        let(:example) { example_name }
        let(:extra_args) do
          if File.exist?("#{cck_path}/#{example}.arguments.txt")
            File.read("#{cck_path}/#{example}.arguments.txt").to_s
          else
            ''
          end
        end
        let(:support_code_path) { CompatibilityKit.supporting_code_for(example) }
        let(:messages) { `#{cucumber_command} --require #{support_code_path} #{cck_path} #{extra_args}` }
      end
    end
  end
end
