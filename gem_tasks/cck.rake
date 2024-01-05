# frozen_string_literal: true

require 'rspec/core/rake_task'

desc 'Run RSpec for the gem against the cucumber compatibility kit'
RSpec::Core::RakeTask.new(:cck) do |t|
  t.verbose = true
  t.rspec_opts = '--tag cck --pattern ../compatibility/cck_spec.rb'

  puts 'Testing CCK proper first'
  sh 'bundle exec rspec compatibility/spec -f d'

  puts 'Now will test the cucumber-ruby gem for CCK conformance'
end
