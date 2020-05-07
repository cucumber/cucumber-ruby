Then('output should be html with title {string}') do |title|
  document = Nokogiri::HTML.parse(command_line.stdout)
  expect(document.xpath('//title').text).to eq(title)
end
