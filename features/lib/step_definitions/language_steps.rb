# encoding: utf-8
# frozen_string_literal: true

Then('cucumber lists all the supported languages') do
  sample_languages = %w(Arabic български Pirate English 日本語)
  sample_languages.each do |language|
    expect(all_output.force_encoding('utf-8')).to include(language)
  end
end
