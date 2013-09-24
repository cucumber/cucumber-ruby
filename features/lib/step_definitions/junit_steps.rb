Given(/^the tmp directory is empty$/) do
  remove_dir 'tmp'
end

Then(/^"(.*?)" with junit duration "(.*?)" should contain$/) do |actual_file, duration, text|
end
