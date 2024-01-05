# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new

default_tasks = %i[spec cucumber cck]
default_tasks << :examples if ENV['CI']
task default: default_tasks
