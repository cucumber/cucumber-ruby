# frozen_string_literal: true

# This blank hook has been re-added in. See https://github.com/cucumber/compatibility-kit/issues/83 for more details
Before { nil }

When('the string {string} is attached as {string}') do |text, media_type|
  attach(text, media_type)
end

When('the string {string} is logged') do |text|
  log(text)
end

When('text with ANSI escapes is logged') do
  log("This displays a \x1b[31mr\x1b[0m\x1b[91ma\x1b[0m\x1b[33mi\x1b[0m\x1b[32mn\x1b[0m\x1b[34mb\x1b[0m\x1b[95mo\x1b[0m\x1b[35mw\x1b[0m")
end

When('the following string is attached as {string}:') do |media_type, doc_string|
  attach(doc_string, media_type)
end

When('an array with {int} bytes is attached as {string}') do |size, media_type|
  data = (0..size - 1).map { |i| [i].pack('C') }.join
  attach(data, media_type)
end

When('a JPEG image is attached') do
  attach(File.open("#{__dir__}/cucumber.jpeg"), 'image/jpeg')
end

When('a PNG image is attached') do
  attach(File.open("#{__dir__}/cucumber.png"), 'image/png')
end

When('a PDF document is attached and renamed') do
  attach(File.open("#{__dir__}/document.pdf"), 'document/pdf', 'renamed.pdf')
end
