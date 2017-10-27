# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 'cucumber'
  s.version     = File.read(File.expand_path('../lib/cucumber/version', __FILE__))
  s.authors     = ["Aslak Hellesøy", 'Matt Wynne', 'Steve Tooke']
  s.description = 'Behaviour Driven Development with elegance and joy'
  s.summary     = "cucumber-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.license     = 'MIT'
  s.homepage    = 'https://cucumber.io/'
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2' # Keep in sync with .circleci/config.yml
  s.add_dependency 'cucumber-core', '~> 3.0.0'
  s.add_dependency 'builder', '>= 2.1.2'
  s.add_dependency 'diff-lcs', '~> 1.3'
  s.add_dependency 'gherkin', '~> 4.0'
  s.add_dependency 'multi_json', '>= 1.7.5', '< 2.0'
  s.add_dependency 'multi_test', '>= 0.1.2'
  s.add_dependency 'cucumber-wire', '~> 0.0.1'
  s.add_dependency 'cucumber-expressions', '~> 4.0.3'

  s.add_development_dependency 'bundler', '~> 1.15.1'
  s.add_development_dependency 'aruba', '~> 0.6.1'
  s.add_development_dependency 'json', '~> 1.8.6'
  s.add_development_dependency 'nokogiri', '~> 1.8.1'
  s.add_development_dependency 'rake', '>= 0.9.2'
  s.add_development_dependency 'rspec', '>= 3.6'
  s.add_development_dependency 'simplecov', '>= 0.6.2'
  s.add_development_dependency 'syntax', '>= 1.0.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rubocop', '~> 0.40.0'

  # For maintainer scripts
  s.add_development_dependency 'octokit'

  # For Documentation:
  s.add_development_dependency 'bcat', '~> 0.6.2'
  s.add_development_dependency 'kramdown', '~> 0.14'
  s.add_development_dependency 'yard', '~> 0.8.0'

  # Needed for examples (rake examples)
  s.add_development_dependency 'capybara', '>= 2.1'
  s.add_development_dependency 'rack-test', '>= 0.6.1'
  s.add_development_dependency 'sinatra', '>= 1.3.2'

  s.rubygems_version = '>= 1.6.1'
  s.files            = Dir[
    'CHANGELOG.md',
    'CONTRIBUTING.md',
    'README.md',
    'LICENSE',
    'lib/**/*'
  ]
  s.executables      = ['cucumber']
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_path     = 'lib'
end
