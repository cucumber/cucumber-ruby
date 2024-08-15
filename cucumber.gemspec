# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'cucumber'
  s.version     = File.read(File.expand_path('VERSION', __dir__)).strip
  s.authors     = ['Aslak Hellesøy', 'Matt Wynne', 'Steve Tooke']
  s.description = 'Behaviour Driven Development with elegance and joy'
  s.summary     = "cucumber-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.license     = 'MIT'
  s.homepage    = 'https://cucumber.io/'
  s.platform    = Gem::Platform::RUBY

  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/cucumber/cucumber-ruby/issues',
    'changelog_uri' => 'https://github.com/cucumber/cucumber-ruby/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/github/cucumber/cucumber-ruby/',
    'mailing_list_uri' => 'https://groups.google.com/forum/#!forum/cukes',
    'source_code_uri' => 'https://github.com/cucumber/cucumber-ruby'
  }

  s.required_ruby_version = '>= 2.7'
  s.required_rubygems_version = '>= 3.0.1'

  s.add_dependency 'builder', '~> 3.2'
  s.add_dependency 'cucumber-ci-environment', '> 9', '< 11'
  s.add_dependency 'cucumber-core', '> 13', '< 15'
  s.add_dependency 'cucumber-cucumber-expressions', '~> 17.0'
  s.add_dependency 'cucumber-gherkin', '> 24', '< 30'
  s.add_dependency 'cucumber-html-formatter', '> 20.3', '< 22'
  s.add_dependency 'cucumber-messages', '> 19', '< 28'
  s.add_dependency 'diff-lcs', '~> 1.5'
  s.add_dependency 'mini_mime', '~> 1.1'
  s.add_dependency 'multi_test', '~> 1.1'
  s.add_dependency 'sys-uname', '~> 1.3'

  s.add_development_dependency 'cucumber-compatibility-kit', '~> 16.2'
  # Only needed whilst we are testing the formatters. Can be removed once we remove tests for those
  s.add_development_dependency 'nokogiri', '~> 1.15'
  s.add_development_dependency 'rake', '~> 13.2'
  s.add_development_dependency 'rspec', '~> 3.13'
  s.add_development_dependency 'rubocop', '~> 1.56.4'
  s.add_development_dependency 'rubocop-capybara', '~> 2.21.0'
  s.add_development_dependency 'rubocop-packaging', '~> 0.5.2'
  s.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  s.add_development_dependency 'rubocop-rspec', '~> 2.25.0'
  s.add_development_dependency 'simplecov', '~> 0.22.0'
  s.add_development_dependency 'webrick', '~> 1.8'

  s.files = Dir['README.md', 'LICENSE', 'VERSION', 'lib/**/*']
  s.executables      = ['cucumber']
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_path     = 'lib'
end
