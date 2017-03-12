# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

$:.unshift(File.dirname(__FILE__) + '/lib')
Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |t|
  t.profile = 'ruby' if Cucumber::RUBY
end

default_tasks = [:spec, :rubocop, :cucumber]

if ENV['TRAVIS']
  ENV['SIMPLECOV']  = 'ci'
  ENV['JRUBY_OPTS'] = [ENV['JRUBY_OPTS'], '--debug'].compact.join(' ')

  require 'coveralls/rake/task'
  Coveralls::RakeTask.new

  default_tasks << 'coveralls:push'
end

task :default => default_tasks

require 'rake/clean'
CLEAN.include %w(**/*.{log,pyc,rbc,tgz} doc)
