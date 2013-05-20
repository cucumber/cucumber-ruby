# encoding: utf-8

Then(/^cucumber lists all the supported languages$/) do
  sample_languages = ["Arabic", "български", "Pirate", "English", "日本語"]
  sample_languages.each do |language|
    all_output.force_encoding('utf-8').should include(language)
  end
end
