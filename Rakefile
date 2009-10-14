require 'rubygems'
require 'rake'
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'cucumber/platform'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cucumber"
    gem.summary = %Q{Behaviour Driven Development with elegance and joy}
    gem.description = %Q{A BDD tool written in Ruby}
    gem.email = "cukes@googlegroups.com"
    gem.homepage = "http://cukes.info"
    gem.authors = ["Aslak Hellesøy"]
    gem.rubyforge_project = "cucumber"

    gem.add_dependency 'term-ansicolor', '1.0.4'
    gem.add_dependency 'treetop', '1.4.2'
    gem.add_dependency 'polyglot', '0.2.9'
    gem.add_dependency 'builder', '2.1.2'
    gem.add_dependency 'diff-lcs', '1.1.2'

    gem.add_development_dependency 'nokogiri', '1.3.3'
    gem.add_development_dependency 'prawn', '0.5.1'
    gem.add_development_dependency 'rspec', '1.2.9'
    gem.add_development_dependency 'spork', '0.7.2'
    
    gem.post_install_message = <<-POST_INSTALL_MESSAGE

(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) 

                     (::)   U P G R A D I N G    (::)

Thank you for installing cucumber-#{Cucumber::VERSION}
Please be sure to read http://wiki.github.com/aslakhellesoy/cucumber/upgrading
for important information about this release.

(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) 

POST_INSTALL_MESSAGE
  end

  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "sdoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

if(Cucumber::RUBY_1_9)
  task :default => [:check_dependencies, :cucumber] # RSpec doesn't run on 1.9 yet.
else
  task :default => [:check_dependencies, :spec, :cucumber]
end

require 'rake/clean'
CLEAN.include %w(**/*.{log,pyc})
