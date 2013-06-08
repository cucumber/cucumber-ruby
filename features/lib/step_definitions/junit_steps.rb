def replace_junit_duration(s, replacement)
  s.gsub(/\d+\.\d\d+/m, replacement)
end

When(/^the junit run with output "(.*?)" took "(.*?)" seconds$/) do |actual_file, duration_replacement|
  file = File.join("tmp", "aruba", actual_file)
  output = IO.read(file)
  output = replace_junit_duration(output, duration_replacement)
  IO.write(file, output)
end
