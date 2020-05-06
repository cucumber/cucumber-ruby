Then('the junit output file {string} should contain:') do |actual_file, text|
  actual = IO.read(File.expand_path('.') + '/' + actual_file)
  actual = remove_self_ref(replace_junit_time(actual))

  expect(actual).to be_similar_output_than(text)
end
