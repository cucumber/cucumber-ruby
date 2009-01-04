class GoogleSearch
  def initialize(browser)
    @browser = browser
  end
  
  def goto
    @browser.goto 'http://www.google.com/'
  end
  
  def search(text)
    @browser.text_field(:name, 'q').set(text)
    @browser.button(:name, 'btnG').click
  end
end

Given 'I am on the Google search page' do
  @page = GoogleSearch.new(@browser)
  @page.goto
end

When /I search for "(.*)"/ do |query|
  @page.search(query)
end

Then /I should see a link to "(.*)":(.*)/ do |text, url|
  @browser.link(:url, url).text.should == text
end
