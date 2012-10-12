# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "cucumber/platform"

Gem::Specification.new do |s|
  s.name        = 'cucumber'
  s.version     = Cucumber::VERSION
  s.authors     = ["Aslak Hellesøy"]
  s.description = 'Behaviour Driven Development with elegance and joy'
  s.summary     = "cucumber-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.homepage    = "http://cukes.info"

  s.platform    = Gem::Platform::RUBY

  s.add_runtime_dependency 'gherkin', '~> 2.11.0'
  s.add_runtime_dependency 'builder', '>= 2.1.2'
  s.add_runtime_dependency 'diff-lcs', '>= 1.1.3'
  s.add_runtime_dependency 'json', '>= 1.4.6'
  
  s.add_development_dependency 'aruba', '~> 0.4.11'
  s.add_development_dependency 'rake', '>= 0.9.2'
  s.add_development_dependency 'rspec', '~> 2.10.0'
  s.add_development_dependency 'nokogiri', '>= 1.5.2'
  s.add_development_dependency 'syntax', '>= 1.0.0'
  s.add_development_dependency 'spork', '>= 1.0.0.rc2'
  s.add_development_dependency 'simplecov', '>= 0.6.2'

  # For Documentation:
  s.add_development_dependency('yard', '~> 0.8.0')
  s.add_development_dependency('rdiscount', '~> 1.6.8') unless defined?(JRUBY_VERSION)
  s.add_development_dependency('bcat', '~> 0.6.2')
    
  # Needed for examples (rake examples)
  s.add_development_dependency 'ramaze'
  s.add_development_dependency 'rack-test', '>= 0.6.1'
  s.add_development_dependency 'webrat', '>= 0.7.3'
  s.add_development_dependency 'sinatra', '>= 1.3.2'
  s.add_development_dependency 'capybara', '>= 1.1.2'

  s.rubygems_version = ">= 1.6.1"
  s.files            = `git ls-files`.split("\n").reject {|path| path =~ /\.gitignore$/ }
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
