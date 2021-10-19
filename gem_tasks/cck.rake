# frozen_string_literal: true

require 'rspec/core/rake_task'

desc 'Run RSpec against the cucumber compatibility kit'
RSpec::Core::RakeTask.new(:cck) do |t|
  t.verbose = true
  t.rspec_opts = '--tag cck'
end
