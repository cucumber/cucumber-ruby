require 'rubygems'
require 'bundler'
require 'rbconfig'
# rubocop:disable Style/DoubleNegation
is_windows = !!(RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
# rubocop:enable Style/DoubleNegation

Bundler::GemHelper.install_tasks

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

default_tasks = %i[spec cucumber]

unless is_windows
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  default_tasks = %i[spec cucumber rubocop]
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new

default_tasks << :examples if ENV['CI']

task default: default_tasks

require 'rake/clean'
CLEAN.include %w[**/*.{log,pyc,rbc,tgz} doc]
