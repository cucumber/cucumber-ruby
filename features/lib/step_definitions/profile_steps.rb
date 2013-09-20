Given /^the following profiles? (?:are|is) defined:$/ do |profiles|
  create_file('cucumber.yml', profiles)
end

Then /^the (.*) profile should be used$/ do |profile|
  last_stdout.should =~ /Using the #{profile} profile/
end

Then /^exactly these files should be loaded:\s*(.*)$/ do |files|
  last_stdout.scan(/^  \* (.*\.rb)$/).flatten.should == files.split(/,\s+/)
end

Then /^exactly these features should be ran:\s*(.*)$/ do |files|
  last_stdout.scan(/^  \* (.*\.feature)$/).flatten.should == files.split(/,\s+/)
end
