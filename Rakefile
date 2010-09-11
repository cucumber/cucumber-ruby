# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

require 'term/ansicolor'
require 'rake'

$:.unshift(File.dirname(__FILE__) + '/lib')
require 'cucumber/formatter/ansicolor'
require 'cucumber/platform'

Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

task :default => [:spec, :cucumber]

require 'rake/clean'
CLEAN.include %w(**/*.{log,pyc})
