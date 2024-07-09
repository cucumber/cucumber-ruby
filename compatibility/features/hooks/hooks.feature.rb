# frozen_string_literal: true

Before do
  # no-op
end

Before(name: 'A named hook') do
  # no-op
end

def cck_asset_path
  "#{Gem.loaded_specs['cucumber-compatibility-kit'].full_gem_path}/features/attachments"
end

When('a step passes') do
  # no-op
end

When('a step fails') do
  raise 'Exception in step'
end

After do
  # no-op
end

After('@some-tag or @some-other-tag') do
  raise 'Exception in conditional hook'
end

After('@with-attachment') do
  attach(File.open("#{cck_asset_path}/cucumber.svg"), 'image/svg+xml')
end
