= Cucumber

The main website is at http://cukes.info/
The documentation is at http://github.com/aslakhellesoy/cucumber/wikis/home/

== Running tests

gem install geminstaller
geminstaller
gem install test-unit # Only do this if you're on Ruby 1.9.1. Might not be needed when a new version of Spork is released.
rake

Note that if you're on Ruby 1.9.1, the RSpec suite will fail because
RSpec doesn' work with Ruby 1.9.1 yet. You can run only the features:

rake cucumber