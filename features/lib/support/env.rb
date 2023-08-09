# frozen_string_literal: true

require 'cucumber/formatter/ansicolor'

CUCUMBER_FEATURES_PATH = 'features/lib'

Before do |scenario|
  @original_cwd = Dir.pwd
  # We limit the length to avoid issues on Windows where sometimes the creation
  # of the temporary directory fails due to the length of the scenario name.
  scenario_name = scenario.name.downcase.gsub(/[^a-z0-9]+/, '-')[0..100]
  @tmp_working_directory = File.join('tmp', "scenario-#{scenario_name}-#{SecureRandom.uuid}")

  FileUtils.rm_rf(@tmp_working_directory)
  FileUtils.mkdir_p(@tmp_working_directory)

  Dir.chdir(@tmp_working_directory)
end

After do |scenario|
  command_line&.destroy_mocks
  Dir.chdir(@original_cwd)
  FileUtils.rm_rf(@tmp_working_directory) unless scenario.failed?
end

Around do |_, block|
  original_publish_token = ENV.delete('CUCUMBER_PUBLISH_TOKEN')
  original_coloring = Cucumber::Term::ANSIColor.coloring?

  block.call

  Cucumber::Term::ANSIColor.coloring = original_coloring
  ENV['CUCUMBER_PUBLISH_TOKEN'] = original_publish_token
end

Around('@force_legacy_loader') do |_, block|
  original_loader = Cucumber.use_legacy_autoloader
  Cucumber.use_legacy_autoloader = true
  block.call
  Cucumber.use_legacy_autoloader = original_loader
end

Before('@global_state') do
  # Ok, this one is tricky but kinda make sense.
  # So, we need to share state between some sub-scenarios (the ones executed by
  # CucumberCommand). But we don't want those to leak between the "real" scenarios
  # (the ones ran by Cucumber itself).
  # This should reset data hopefully (and make clear why we do that)

  # rubocop:disable Style/GlobalVars
  $global_state = nil
  $global_cukes = 0
  $scenario_runs = 0
  # rubocop:enable Style/GlobalVars
end

After('@disable_fail_fast') do
  Cucumber.wants_to_quit = false
end
