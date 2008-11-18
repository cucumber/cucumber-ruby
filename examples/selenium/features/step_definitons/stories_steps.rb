require 'spec'
require 'selenium'

class GoogleSearch
  def initialize(browser)
    @browser = browser
  end
  
  def goto
    @browser.open 'http://www.google.com/'
  end
  
  def search(text)
    @browser.type('q',text)   
    @browser.click 'btnG'
    @browser.wait_for_page_to_load
  end
end

Before do
  @browser = Selenium::SeleniumDriver.new("localhost", 4444, "*chrome", "http://localhost", 15000)
  @browser.start
end

After do
  @browser.stop
end

Given 'I am on the Google search page' do
  @page = GoogleSearch.new(@browser)
  @page.goto
end

When /I search for "(.*)"/ do |query|
  @page.search(query)
end

Then /I should see a link to "(.*)":(.*)/ do |text, expected_url|
  observed_url = @browser.get_attribute("link=#{text}@href")
  observed_url.should == expected_url
end
