# frozen_string_literal: true

def cck_asset_path
  "#{Gem.loaded_specs['cucumber-compatibility-kit'].full_gem_path}/features/hooks-attachment"
end

Before do
  attach(File.open("#{cck_asset_path}/cucumber.svg"), 'image/svg+xml')
end

After do
  attach(File.open("#{cck_asset_path}/cucumber.svg"), 'image/svg+xml')
end

When('a step passes') do
  # no-op
end
