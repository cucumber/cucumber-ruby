Given /^the following profiles? (?:are|is) defined:$/ do |profiles|
  step 'a file named "cucumber.yml" with:', profiles
end

Then /^the (.*) profile should be used$/ do |profile|
  step 'the stdout should contain:', profile
end

Then /^exactly these files should be loaded:\s*(.*)$/ do |files|
  all_stdout.scan(/^  \* (.*\.rb)$/).flatten.should == files.split(/,\s+/)
end

Then /^exactly these features should be ran:\s*(.*)$/ do |files|
  all_stdout.scan(/^  \* (.*\.feature)$/).flatten.should == files.split(/,\s+/)
end
