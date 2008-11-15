# Commonly used webrat steps
# http://github.com/brynary/webrat

require 'webrat' if !defined?(Webrat) # Because some people have it installed as a Gem

When /^I press "(.*)"$/ do |button|
  clicks_button(button)
end

When /^I follow "(.*)"$/ do |link|
  clicks_link(link)
end

When /^I fill in "(.*)" with "(.*)"$/ do |field, value|
  fills_in(field, :with => value) 
end

When /^I select "(.*)" from "(.*)"$/ do |value, field|
  selects(value, :from => field) 
end

When /^I select "(.*)" as the date and time$/ do |time|
  selects_datetime(time)
end

When /^I select "(.*)" as the "(.*)" date and time$/ do |datetime, datetime_label|
  selects_datetime(datetime, :from => datetime_label)
end

When /^I select "(.*)" as the time$/ do |time|
  selects_time(time)
end

When /^I select "(.*)" as the "(.*)" time$/ do |time, time_label|
  selects_time(time, :from => time_label)
end

When /^I select "(.*)" as the date$/ do |date|
  selects_date(date)
end

When /^I select "(.*)" as the "(.*)" date$/ do |date, date_label|
  selects_date(date, :from => date_label)
end

When /^I check "(.*)"$/ do |field|
  checks(field) 
end

When /^I uncheck "(.*)"$/ do |field|
  unchecks(field) 
end

When /^I choose "(.*)"$/ do |field|
  chooses(field)
end

When /^I attach the file at "(.*)" to "(.*)" $/ do |path, field|
  attaches_file(field, path)
end

Then /^I should see "(.*)"$/ do |text|
  response.body.should =~ /#{text}/m
end

Then /^I should not see "(.*)"$/ do |text|
  response.body.should_not =~ /#{text}/m
end

Then /^the "(.*)" checkbox should be checked$/ do |label|
  field_labeled(label).should be_checked
end
