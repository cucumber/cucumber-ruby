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

# Use this step in conjunction with Rail's datetime_select helper. For example:
# When I select "December 25, 2008 10:00" as the date and time 
When /^I select "(.*)" as the date and time$/ do |time|
  selects_datetime(time)
end

# Use this step when using multiple datetime_select helpers on a page or 
# you want to specify which datetime to select. Given the following view:
#   <%= f.label :preferred %><br />
#   <%= f.datetime_select :preferred %>
#   <%= f.label :alternative %><br />
#   <%= f.datetime_select :alternative %>
# The following steps would fill out the form:
# When I select "November 23, 2004 11:20" as the "Preferred" data and time
# And I select "November 25, 2004 10:30" as the "Alternative" data and time
When /^I select "(.*)" as the "(.*)" date and time$/ do |datetime, datetime_label|
  selects_datetime(datetime, :from => datetime_label)
end

# Use this step in conjuction with Rail's time_select helper. For example:
# When I select "2:20PM" as the time
# Note: Rail's default time helper provides 24-hour time-- not 12 hour time. Webrat
# will convert the 2:20PM to 14:20 and then select it. 
When /^I select "(.*)" as the time$/ do |time|
  selects_time(time)
end

# Use this step when using multiple time_select helpers on a page or you want to
# specify the name of the time on the form.  For example:
# When I select "7:30AM" as the "Gym" time
When /^I select "(.*)" as the "(.*)" time$/ do |time, time_label|
  selects_time(time, :from => time_label)
end

# Use this step in conjuction with Rail's date_select helper.  For example:
# When I select "February 20, 1981" as the date
When /^I select "(.*)" as the date$/ do |date|
  selects_date(date)
end

# Use this step when using multiple date_select helpers on one page or
# you want to specify the name of the date on the form. For example:
# When I select "April 26, 1982" as the "Date of Birth" date
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
