begin
  require 'rspec/core/rake_task'

  desc "Run RSpec"
  RSpec::Core::RakeTask.new do |t|
    t.rcov = ENV['RCOV']
    t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
    t.verbose = true
  end
rescue LoadError => e
  require 'spec/rake/spectask'

  desc "Run RSpec"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = %w{--color --diff}
    t.rcov = ENV['RCOV']
    t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
    t.verbose = true
  end
end
