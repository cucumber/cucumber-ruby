require 'stringio'

# Cucumber-JVM needs to use a Before hook in order to create attachments
Before do
  # no-op
end

When('the string {string} is attached as {string}') do |text, media_type|
  embed(text, media_type)
end

When('an array with {int} bytes are attached as {string}') do |size, media_type|
  data = (0..size-1).map {|i| [i].pack('C') }.join
  embed(data, media_type)
end

When('a stream with {int} bytes are attached as {string}') do |size, media_type|
  stream = StringIO.new
  stream.puts (0..size).map(&:to_s).join('')
  stream.seek(0)

  embed(stream, media_type)
end

When('a JPEG image is attached') do
  embed(File.open("#{__dir__}/cucumber-growing-on-vine.jpg"), 'image/jpg')
end