## About to create a new Github Issue?

We appreciate that. But before you do, please learn our basic rules:

* This is not a support forum. If you have a question, please go to [The Cukes Google Group](http://groups.google.com/group/cukes).
* Do you have an idea for a new feature? Then don't expect it to be implemented unless you or someone else sends a [pull request](https://help.github.com/articles/using-pull-requests). You might be better to start a discussion on [the google group](http://groups.google.com/group/cukes).
* Reporting a bug? Please tell us:
  * which version of Cucumber you're using
  * which version of Ruby you're using.
  * How to reproduce it. Bugs with a failing test in a [pull request](https://help.github.com/articles/using-pull-requests) get fixed much quicker. Some bugs may never be fixed.
* Want to paste some code or output? Put \`\`\` on a line above and below your code/output. See [GFM](https://help.github.com/articles/github-flavored-markdown)'s *Fenced Code Blocks* for details.
* We love [pull requests](https://help.github.com/articles/using-pull-requests). But if you don't have a test to go with it we probably won't merge it.

# Contributing to Cucumber

The rest of this document is a guide for those maintaining Cucumber, and others who would like to submit patches.

## Talking with other devs

You can chat with the core team on https://gitter.im/cucumber/contributors. We try to have office hours on Fridays.

## Installing your own gems

A `Gemfile.local`-file can be used to have your own gems installed to support
your normal development workflow.

Example:

~~~ruby
gem 'pry'
gem 'pry-byebug'
gem 'byebug'
~~~

## Note on Patches/Pull Requests

* Fork the project. Make a branch for your change.
* Make your feature addition or bug fix.
* Make sure your patch is well covered by tests. We don't accept changes to Cucumber that aren't tested.
* Please do not change the Rakefile, version, or history.
  (if you want to have your own version, that is fine but
  bump version in a commit by itself so we can ignore when we merge your change)
* Send us a pull request.

## Running tests

    gem install bundler
    bundle install
    bundle exec rake

    To get code coverage results, run `bundle exec rake cov`

## First timer? No problem!

If you are new to the project or to OSS, check the label
[Easy](https://github.com/cucumber/cucumber-ruby/labels/Easy). Also, you can
help us to correct style violations reported here:
[.rubocop_todo.yml](https://github.com/cucumber/cucumber-ruby/blob/master/.rubocop_todo.yml).

## Release Process

* Bump the version number in `lib/cucumber/version`.
* Make sure `CHANGELOG.md` is updated with the upcoming version number, and has entries for all fixes.

Now release it

    bundle update
    bundle exec rake
    git commit -m "Release X.Y.Z"
    # Make sure you run gem signin as the cukebot@cucumber.io user before running the following step. Credentials can be found in 1Password
    rake release
