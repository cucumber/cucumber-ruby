$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber/rake/task'

puts "********* Run-Code-Run debugging. I am in #{File.expand_path(__FILE__)}"

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format progress}
  t.cucumber_opts += %w{--profile runcoderun} if File.expand_path(__FILE__) =~ /~\/mnt\/repos/
  t.rcov = ENV['RCOV']
end

Cucumber::Rake::Task.new('pretty') do |t|
  t.cucumber_opts = %w{--format pretty}
end