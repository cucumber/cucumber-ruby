# frozen_string_literal: true

Then('output should be binary protobuf messages') do
  Cucumber::Messages::BinaryToMessageEnumerator.new(all_stdout) do | message |
    # puts message
  end
end
