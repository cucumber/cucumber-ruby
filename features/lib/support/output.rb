require 'rspec/expectations'

def clean_output(output)
  output.split("\n").map do |line|
    next if line.include?(CUCUMBER_FEATURES_PATH)
    line
      .gsub(/\e\[([;\d]+)?m/, '')                  # Drop colors
      .gsub(/^.*cucumber_process\.rb.*$\n/, '')
      .gsub(/^\d+m\d+\.\d+s$/, '0m0.012s')         # Make duration predictable
      .gsub(/Coverage report generated .+$\n/, '') # Remove SimpleCov message
      .sub(/\s*$/, '')                             # Drop trailing whitespaces
  end.compact.join("\n")
end

def remove_self_ref(output)
  output
    .split("\n")
    .reject { |line| line.include?(CUCUMBER_FEATURES_PATH) }
    .join("\n")
end

RSpec::Matchers.define :be_similar_output_than do |expected|
  match do |actual|
    @actual = clean_output(actual)
    @expected = clean_output(expected)
    @actual == @expected
  end

  diffable
end

RSpec::Matchers.define :start_with_output do |expected|
  match do |actual|
    @actual = clean_output(actual)
    @expected = clean_output(expected)
    @actual.start_with?(@expected)
  end

  diffable
end

RSpec::Matchers.define :include_output do |expected|
  match do |actual|
    @actual = clean_output(actual)
    @expected = clean_output(expected)
    @actual.include?(@expected)
  end

  diffable
end
