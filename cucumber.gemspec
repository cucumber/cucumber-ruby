Gem::Specification.new do |s|
  s.name        = 'cucumber'
  s.version     = File.read(File.expand_path('lib/cucumber/version', __dir__)).strip
  s.authors     = ['Aslak Hellesøy', 'Matt Wynne', 'Steve Tooke']
  s.description = 'Behaviour Driven Development with elegance and joy'
  s.summary     = "cucumber-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.license     = 'MIT'
  s.homepage    = 'https://cucumber.io/'
  s.platform    = Gem::Platform::RUBY

  s.metadata    = {
    'bug_tracker_uri'   => 'https://github.com/cucumber/cucumber-ruby/issues',
    'changelog_uri'     => 'https://github.com/cucumber/cucumber-ruby/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/github/cucumber/cucumber-ruby/',
    'mailing_list_uri'  => 'https://groups.google.com/forum/#!forum/cukes',
    'source_code_uri'   => 'https://github.com/cucumber/cucumber-ruby'
  }

  # Keep in sync with .circleci/config.yml & .rubocop.yml
  s.required_ruby_version = '>= 2.5'
  s.add_dependency 'builder', '~> 3.2', '>= 3.2.4'
  s.add_dependency 'cucumber-ci-environment', '~> 8.1', '>= 8.1.0'
  s.add_dependency 'cucumber-core', '~> 10.1', '>= 10.1.1'
  s.add_dependency 'cucumber-cucumber-expressions', '~> 15.0', '>= 15.0.1'
  s.add_dependency 'cucumber-gherkin', '~> 22.0', '>= 22.0.0'
  s.add_dependency 'cucumber-html-formatter', '~> 17.0', '>= 17.0.0'
  s.add_dependency 'cucumber-messages', '~> 17.1', '>= 17.1.1'
  s.add_dependency 'diff-lcs', '~> 1.5', '>= 1.5.0'
  s.add_dependency 'mime-types', '~> 3.4', '>= 3.4.1'
  s.add_dependency 'multi_test', '~> 0.1', '>= 0.1.2'
  s.add_dependency 'sys-uname', '~> 1.2', '>= 1.2.2'

  s.add_development_dependency 'cucumber-compatibility-kit', '~> 9.1', '>= 9.1.2'
  s.add_development_dependency 'nokogiri', '~> 1.13', '>= 1.13.1'
  s.add_development_dependency 'pry', '~> 0.14', '>= 0.14.1'
  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  s.add_development_dependency 'rspec', '~> 3.10', '>= 3.10.0'
  s.add_development_dependency 'simplecov', '~> 0.21', '>= 0.21.2'
  s.add_development_dependency 'syntax', '~> 1.2', '>= 1.2.2'
  s.add_development_dependency 'test-unit', '~> 3.5', '>= 3.5.3'
  s.add_development_dependency 'webrick', '~> 1.7', '>= 1.7.0'

  # For maintainer scripts
  s.add_development_dependency 'octokit', '~> 4.22', '>= 4.22.0'

  # Needed for examples (rake examples)
  s.add_development_dependency 'rack-test', '~> 1.1', '>= 1.1.0'
  s.add_development_dependency 'sinatra', '~> 2.1', '>= 2.1.0'
  # Capybara dropped support for Ruby 2.3 in 3.16.0 - keep 3.15.0 while we're still supporting ruby 2.3
  s.add_development_dependency 'capybara', '~> 3.36', '>= 3.36.0'

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
