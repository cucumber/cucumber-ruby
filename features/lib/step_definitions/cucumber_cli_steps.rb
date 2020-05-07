Then('I should see the CLI help') do
  expect(command_line.stdout).to include('Usage:')
end

Then('cucumber lists all the supported languages') do
  sample_languages = %w[Arabic български Pirate English 日本語]
  sample_languages.each do |language|
    expect(command_line.stdout.force_encoding('utf-8')).to include(language)
  end
end
