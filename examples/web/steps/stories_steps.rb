require 'spec'

case PLATFORM
when /darwin/
  require 'safariwatir'
  Watir::Browser = Watir::Safari
when /win32/
  require 'watir'
  Watir::Browser = Watir::IE
else
  raise "Can't use Watir on #{PLATFORM}"
end

Before do
  @b = Watir::Browser.new
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
