# frozen_string_literal: true

require 'rspec/core/rake_task'

desc 'Run RSpec'
RSpec::Core::RakeTask.new do |t|
  t.verbose = true
  t.rspec_opts = '--tag ~cck'
end
