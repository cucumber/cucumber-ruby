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
    'bug_tracker_uri'   => 'https://github.com/cucumber/cucumber-ruby/issues',
    'changelog_uri'     => 'https://github.com/cucumber/cucumber-ruby/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/github/cucumber/cucumber-ruby/',
    'mailing_list_uri'  => 'https://groups.google.com/forum/#!forum/cukes',
    'source_code_uri'   => 'https://github.com/cucumber/cucumber-ruby'
  }

  s.required_ruby_version = '>= 2.7'

  s.add_dependency 'builder', '~> 3.2', '>= 3.2.4'
  s.add_dependency 'cucumber-ci-environment', '~> 9.2', '>= 9.2.0'
  s.add_dependency 'cucumber-core', '~> 11.0', '>= 11.0.0'
  s.add_dependency 'cucumber-cucumber-expressions', '~> 16.1', '>= 16.1.2'
  s.add_dependency 'cucumber-gherkin', '>= 23', '< 26.2.1'
  s.add_dependency 'cucumber-html-formatter', '~> 20.4', '>= 20.4.0'
  s.add_dependency 'cucumber-messages', '>= 18', '< 23'
  s.add_dependency 'diff-lcs', '~> 1.5', '>= 1.5.0'
  s.add_dependency 'mini_mime', '~> 1.1', '>= 1.1.5'
  s.add_dependency 'multi_test', '~> 1.1', '>= 1.1.0'
  s.add_dependency 'sys-uname', '~> 1.2', '>= 1.2.3'

  s.add_development_dependency 'cucumber-compatibility-kit', '~> 9.2', '>= 9.2.1'
  s.add_development_dependency 'nokogiri', '~> 1.13', '>= 1.13.6'
  s.add_development_dependency 'pry', '~> 0.14', '>= 0.14.1'
  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  s.add_development_dependency 'rspec', '~> 3.12', '>= 3.12.0'
  s.add_development_dependency 'rubocop', '1.43.0'
  s.add_development_dependency 'rubocop-packaging', '~> 0.5.2'
  s.add_development_dependency 'simplecov', '~> 0.22', '>= 0.22.0'
  s.add_development_dependency 'syntax', '~> 1.2', '>= 1.2.2'
  s.add_development_dependency 'test-unit', '~> 3.6', '>= 3.6.1'
  s.add_development_dependency 'webrick', '~> 1.8', '>= 1.8.1'

  # For maintainer scripts
  s.add_development_dependency 'octokit', '~> 6.0', '>= 6.1.0'

  # Needed for rake examples
  s.add_development_dependency 'capybara', '~> 3.39', '>= 3.39.2'
  s.add_development_dependency 'rack-test', '~> 2.1', '>= 2.1.0'
  s.add_development_dependency 'sinatra', '~> 3.1', '>= 3.1.0'

  s.required_rubygems_version = '>= 3.0.1'
  s.files = Dir[
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
