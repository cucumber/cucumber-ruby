# frozen_string_literal: true

Given('a directory named {string}') do |path|
  FileUtils.mkdir_p(path)
end

Given('a file named {string} with:') do |path, content|
  write_file(path, content)
end

Given('an empty file named {string}') do |path|
  write_file(path, '')
end

Then('a file named {string} should exist') do |path|
  expect(File.file?(path)).to be true
end
