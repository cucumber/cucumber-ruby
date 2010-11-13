$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber/rake/task'
require 'cucumber/platform'

Cucumber::Rake::Task.new(:features) do |t|
  if(Cucumber::JRUBY)
    t.profile = Cucumber::WINDOWS ? 'jruby_win' : 'jruby'
  elsif(Cucumber::WINDOWS_MRI)
    t.profile = 'windows_mri'
  elsif(Cucumber::RUBY_1_9)
    t.profile = 'ruby_1_9'
  end
  t.rcov = ENV['RCOV']
end

Cucumber::Rake::Task.new(:aruba_features) do |t|
  t.cucumber_opts = %w{aruba_features}
end

task :cucumber => [:aruba_features]