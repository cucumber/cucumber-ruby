# Contributing to Cucumber

Thank you for considering contributing to Cucumber!

This document will first introduce different ways to get involved before
focusing on how to contribute to the code.

## Code of Conduct

Everyone interacting in this codebase and issue tracker is expected to follow
the Cucumber [code of conduct](https://cucumber.io/conduct).

## How can I contribute?

If you read this, you are certainly looking to contribute to the code. Cucumber
is not this single repository. It is made up of several packages around several
repositories. So before going further with the code, you may consider the
following first, in order to get your bearings.

If you just want to know how to contribute to the code, go to
[Contribute to the code](#contribute-to-the-code).

If you want to report an issue, or suggest an enhancement, go to
[Report bugs and submit feature requests](#report-bugs-and-submit-feature-requests).

### Meet the community, the maintainers, and other Cucumber developers

Smartbear is hosting a [community message board][cucumber-smartbear-community].
This is a good place to meet users, the community, and to ask questions.

You can also join the Cucumber Community Slack team:
[register for an account][register-slack] then head over to [#intro][slack-intro].
This is the place to be to meet the maintainers aka the core team.

### Test Cucumber

Testing Cucumber, especially new features, is a great way to contribute. We
cannot put a price on (early) feedback.

Keep an eye on our CHANGELOGS to discover new features. Test and experiment, and
submit your feedback through [issues](#report-bugs-and-submit-feature-requests),
the [community message board][cucumber-smartbear-community], or [Slack][community-slack].

### Contribute to the documentation

[The documentation][cucumber-docs] is an important part of Cucumber. It is
essential that it remains simple and accurate. You can contribute to it via
[github.com/cucumber/docs](https://github.com/cucumber/docs).

### Promote Cucumber

You don't know how to contribute but would like to help? Telling other people
about Cucumber on the Internet - social media, reviews, blogs - but also in real
life is already a big help! Join us on [Slack][community-slack] to share your
publication and to discover new ones.

## Report bugs and submit feature requests

The short version is:

- Find the appropriate repository
- Make sure there is not already an issue or pull request that deals with your
  bug or request
- Consider submitting a pull request if you feel confident enough
- Explain your issue and include as much details as possible to help other
  people reproduce your problem or understand your request

You can find more details for each of these steps in the following sections.

### Find the appropriate repository

The current repository, `cucumber-ruby`, is actually the tip of the iceberg. It
provides a user interface through a CLI, some built-in formatters, and the
execution environment you may know as the `World` object.

An important repository is [cucumber/common]. It is a mono-repo
with a lot of libraries. You will find there what is related to:

- parsing Gherkin documents - aka `.feature` files
- parsing tag expressions - the options you use to filter an execution with tags
- parsing Cucumber expressions - the expressions that link a Gherkin step to a
  step definition
- everyting related to the HTML formatter

`cucumber-ruby` is also composed of:

- [cucumber-ruby-core]: this is the engine that will execute the test cases
  computed from a parsed Gherkin document
- [cucumber-ruby-wire]: everything related to the Cucumber's wire protocol

Last but not least, there is also a repository for [cucumber-rails], the gem
that brings Cucumber to Rails 5.x and 6.x.

In any case, if your are not sure, the best places to open an issue are the
current repository - `cucumber-ruby` - and the mono-repo at [cucumber/common].

### Look for existing issues and pull requests

Search in [the current repository][cucumber-ruby-issues], in the
[mono-repo][cucumber/common-issues], but also in the
[whole cucumber team][cucumber-issues] if the problem or feature has already
been reported. If you find an issue or pull request which is still open, add
comments to it instead of opening a new one.

### Submitting a pull request

When submitting a pull request:

- create a draft pull request
- try to follow the instructions in the [template](.github/PULL_REQUEST_TEMPLATE.md)
- if possible, [sign your commits][github-sign-commits]
- update CHANGELOG.md with your changes
- once the PR is ready, request for reviews

More info on [how to contribute to the code](#contribute-to-the-code) can be
found below.

### Opening a new issue

To open a good issue, be clear and precise.

If you report a problem, the reader must be able to reproduce it easily.
Please do your best to create a [minimal, reproducible example][minimal-reproducible-example].

Consider submitting a pull request. Even if you think you cannot fix it by
yourself, a pull request with a failing test is always welcome.

If you request for an enhancement - a new feature, be specific, support your
request with referenced facts and include examples to illustrate your proposal.

## Contribute to the code

### Development environment

Development environment for `cucumber-ruby` is a simple Ruby environment with
Bundler. Use a [supported Ruby version](./README.md#supported-platforms), make
sure [Bundler] is set-up, and voilà!




[cucumber-smartbear-community]: https://community.smartbear.com/t5/Cucumber-Open/bd-p/CucumberOS
[register-slack]: https://cucumberbdd-slack-invite.herokuapp.com/
[slack-intro]: https://cucumberbdd.slack.com/messages/C5WD8SA21/
[community-slack]: https://cucumberbdd.slack.com/
[cucumber-docs]: https://cucumber.io/docs/cucumber
[cucumber/common]: https://github.com/cucumber/common
[cucumber-ruby-core]: https://github.com/cucumber/cucumber-ruby-core
[cucumber-ruby-wire]: https://github.com/cucumber/cucumber-ruby-wire
[cucumber-rails]: https://github.com/cucumber/cucumber-rails
[cucumber-ruby-issues]: https://github.com/cucumber/cucumber-ruby/search?q=is%3Aissue
[cucumber/common-issues]: https://github.com/cucumber/common/search?q=is%3Aissue
[cucumber-issues]: https://github.com/search?q=is%3Aissue+user%3Acucumber
[github-sign-commits]: https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/signing-commits
[minimal-reproducible-example]: https://stackoverflow.com/help/minimal-reproducible-example
[RVM]: https://rvm.io/
[rbenv]: https://github.com/rbenv/rbenv
[Bundler]: https://bundler.io/

------------------------------------------------------------
<!-- Below that is the former content of CONTRIBUTING.md -->


## About to create a new Github Issue?

We appreciate that. But before you do, please learn our basic rules:

- This is not a support forum. If you have a question, please go to [The Cukes Google Group](http://groups.google.com/group/cukes).
- Do you have an idea for a new feature? Then don't expect it to be implemented unless you or someone else sends a [pull request](https://help.github.com/articles/using-pull-requests). You might be better to start a discussion on [the google group](http://groups.google.com/group/cukes).
- Reporting a bug? Please tell us:
  - which version of Cucumber you're using
  - which version of Ruby you're using.
  - How to reproduce it. Bugs with a failing test in a [pull request](https://help.github.com/articles/using-pull-requests) get fixed much quicker. Some bugs may never be fixed.
- Want to paste some code or output? Put \`\`\` on a line above and below your code/output. See [GFM](https://help.github.com/articles/github-flavored-markdown)'s _Fenced Code Blocks_ for details.
- We love [pull requests](https://help.github.com/articles/using-pull-requests). But if you don't have a test to go with it we probably won't merge it.

# Contributing to Cucumber

The rest of this document is a guide for those maintaining Cucumber, and others who would like to submit patches.

## Talking with other devs

You can chat with the core team on https://gitter.im/cucumber/contributors. We try to have office hours on Fridays.

## Installing your own gems

A `Gemfile.local`-file can be used to have your own gems installed to support your normal development workflow.
Execute `bundle config set --local gemfile Gemfile.local` to use it per default.

Example:

```ruby
# Include the regular Gemfile
eval File.read('Gemfile')

group :development do
  gem 'byebug'
  gem 'debase', require: false
  gem 'ruby-debug-ide', require: false
  gem 'pry'
  gem 'pry-byebug'
end
```

## Using Visual Studio Code?

Sample for launch.json configuration is available in
[docs/vscode-example-launch-configuration.md](https://github.com/cucumber/cucumber-ruby/blob/main/docs/vscode-example-launch-configuration.md)

## Note on Patches/Pull Requests

- Fork the project. Make a branch for your change.
- Make your feature addition or bug fix.
- Make sure your patch is well covered by tests. We don't accept changes to Cucumber that aren't tested.
- Please do not change the Rakefile, version, or history.
  (if you want to have your own version, that is fine but
  bump version in a commit by itself so we can ignore when we merge your change)
- Send us a pull request.

## Running tests

    gem install bundler
    bundle install
    bundle exec rake

    To get code coverage results, run `bundle exec rake cov`

## First timer? Welcome!

If you are new to the project or to OSS, check the label
[Easy](https://github.com/cucumber/cucumber-ruby/labels/Easy). Also, you can
help us to correct style violations reported here:
[.rubocop_todo.yml](https://github.com/cucumber/cucumber-ruby/blob/main/.rubocop_todo.yml).

## Release Process

- Upgrade gems with `scripts/update-gemspec`
- Bump the version number in `lib/cucumber/version`
- Update `CHANGELOG.md` with the upcoming version number and create a new `In Git` section
- Remove empty sections from `CHANGELOG.md`
- Now release it:

  ```
  git commit -am "Release X.Y.Z"
  make release
  ```

- Finally, update the cucumber-ruby version in the [documentation project](https://cucumber.io/docs/installation/) in [versions.yaml](https://github.com/cucumber/docs/blob/master/data/versions.yaml) file.
