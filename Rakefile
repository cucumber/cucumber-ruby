# encoding: utf-8
require 'rubygems'
require 'term/ansicolor'
require 'rake'
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'cucumber/formatter/ansicolor'
require 'cucumber/platform'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cucumber"
    gem.summary = %Q{Behaviour Driven Development with elegance and joy}
    gem.description = %Q{Behaviour Driven Development with elegance and joy}
    gem.email = "cukes@googlegroups.com"
    gem.homepage = "http://cukes.info"
    gem.authors = ["Aslak Hellesøy"]

    gem.add_dependency 'gherkin', '~> 2.1.4'
    gem.add_dependency 'term-ansicolor', '~> 1.0.4'
    gem.add_dependency 'builder', '~> 2.1.2'
    gem.add_dependency 'diff-lcs', '~> 1.1.2'
    gem.add_dependency 'json_pure', '~> 1.4.3'

    gem.add_development_dependency 'nokogiri', '~> 1.4.2'
    gem.add_development_dependency 'prawn', '= 0.8.4'
    gem.add_development_dependency 'prawn-layout', '= 0.8.4'
    gem.add_development_dependency 'rspec', '~> 2.0.0.beta.15'
    gem.add_development_dependency 'syntax', '~> 1.0.0'
    gem.add_development_dependency 'spork', '~> 0.8.4' unless Cucumber::JRUBY || Cucumber::WINDOWS

    extend Cucumber::Formatter::ANSIColor
    gem.post_install_message = <<-POST_INSTALL_MESSAGE

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
