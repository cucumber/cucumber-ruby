When('the string {string} is attached as {string}') do |message, media_type|
  expect(message).not_to be_empty
  expect(media_type).not_to be_empty
end

When('an array with {int} bytes are attached as {string}') do |count, media_type|
  expect(count).not_to be_nil
  expect(media_type).not_to be_empty
end

When('a stream with {int} bytes are attached as {string}') do |count, media_type|
  expect(count).not_to be_nil
  expect(media_type).not_to be_empty
end
