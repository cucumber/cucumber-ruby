# Full Watir API: http://wtr.rubyforge.org/rdoc/
# Full RSpec API: http://rspec.rubyforge.org/

Given 'I am on the Google search page' do
  @browser.goto 'http://www.google.com/'
end

When /I search for "(.*)"/ do |query|
  @browser.text_field(:name, 'q').set(query)
  @browser.button(:name, 'btnG').click
end

Then /I should see a link to "(.*)":(.*)/ do |text, url|
  link = @browser.link(:url, url)
  link.should_not == nil
  link.text.should == text
end

# To avoid step definitions that are tightly coupled to your user interface,
# consider creating classes for your pages - such as this:
# http://github.com/aslakhellesoy/cucumber/tree/v0.1.15/examples/watir/features/step_definitons/search_steps.rb
#
# You may keep the page classes along your steps, or even better, put them in separate files, e.g.
# support/pages/google_search.rb