Given(/^the tmp directory is empty$/) do
  remove_dir 'tmp'
end

Then(/^"(.*?)" with junit duration "(.*?)" should contain$/) do |actual_file, duration, text|
  actual = IO.read(current_dir + '/' + actual_file)
  actual = replace_junit_duration(actual, duration)
  actual.should == text
end

def replace_junit_duration(s, replacement)
  s.gsub(/\d+\.\d\d+/m, replacement)
end
