require 'spec'

case PLATFORM
when /darwin/
  require 'safariwatir'
  Browser = Watir::Safari
when /win32/
  require 'watir'
  Browser = Watir::IE
when /java/
  require 'celerity'
  Browser = Celerity::Browser
else
  raise "Can't do web stories on #{PLATFORM}"
end

Before do
  @b = Browser.new
end

After do
  @b.close
end

Given 'I am on the search page' do
  @b.goto 'http://www.google.com/'
end

Given /I have entered "(.*)"/ do |query|
  @b.text_field(:name, 'q').set(query)
end

When 'I search' do
  @b.button(:name, 'btnG').click
end

Then /I should see a link to "(.*)":(.*)/ do |text, url|
  @b.link(:url, url).text.should == text
end
