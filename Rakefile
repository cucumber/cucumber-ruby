# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.setup

require 'term/ansicolor'
require 'rake'

$:.unshift(File.dirname(__FILE__) + '/lib')
require 'cucumber/formatter/ansicolor'
require 'cucumber/platform'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "cucumber"
    gemspec.summary = %Q{Behaviour Driven Development with elegance and joy}
    gemspec.description = %Q{Behaviour Driven Development with elegance and joy}
    gemspec.email = "cukes@googlegroups.com"
    gemspec.homepage = "http://cukes.info"
    gemspec.authors = ["Aslak Hellesøy"]

    gemspec.add_bundler_dependencies
    
    extend Cucumber::Formatter::ANSIColor
    gemspec.post_install_message = <<-POST_INSTALL_MESSAGE

#{cukes(15)}

                     #{cukes(1)}   U P G R A D I N G    #{cukes(1)}

Thank you for installing cucumber-#{Cucumber::VERSION}.
Please be sure to read http://wiki.github.com/aslakhellesoy/cucumber/upgrading
for important information about this release. Happy cuking!

#{cukes(15)}

POST_INSTALL_MESSAGE
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

task :default => [:check_dependencies, :spec, :cucumber]

require 'rake/clean'
CLEAN.include %w(**/*.{log,pyc})
