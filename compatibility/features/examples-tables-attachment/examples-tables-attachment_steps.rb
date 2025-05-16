# frozen_string_literal: true

def cck_asset_path
  "#{Gem.loaded_specs['cucumber-compatibility-kit'].full_gem_path}/features/examples-tables-attachment"
end

When('a JPEG image is attached') do
  attach(File.open("#{cck_asset_path}/cucumber.jpeg"), 'image/jpeg')
end

When('a PNG image is attached') do
  attach(File.open("#{cck_asset_path}/cucumber.png"), 'image/png')
end
