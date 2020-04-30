NORUBA_PATH = 'noruba/features/lib'

def clean_output(output)
  output.split("\n").map do |line|
    next if line.include?(NORUBA_PATH)
    line
      .gsub(/\e\[([;\d]+)?m/, '')                  # Drop colors
      .gsub(/^.*cucumber_process\.rb.*$\n/, '')
      .gsub(/^\d+m\d+\.\d+s$/, '0m0.012s')         # Make duration predictable
      .gsub(/Coverage report generated .+$\n/, '') # Remove SimpleCov message
      .sub(/\s*$/, '')                             # Drop trailing whitespaces
  end.compact.join("\n")
end

def remove_self_ref(output)
  output.split("\n")
    .reject { |line| line.include?(NORUBA_PATH) }
    .join("\n")
end

def output_starts_with(source, expected)
  expect(clean_output(source)).to start_with(clean_output(expected))
end

def output_equals(source, expected)
  expect(clean_output(source)).to eq(clean_output(expected))
end

def output_include(source, expected)
  expect(clean_output(source)).to include(clean_output(expected))
end

def output_include_not(source, expected)
  expect(clean_output(source)).not_to include(clean_output(expected))
end
