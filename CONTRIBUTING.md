# Contributing to Cucumber

Thank you for considering contributing to Cucumber!

This document will first introduce different ways to get involved before
focusing on how to contribute to the code.

## Code of Conduct

Everyone interacting in this codebase and issue tracker is expected to follow
the Cucumber [code of conduct](https://cucumber.io/conduct).

## How can I contribute?

If you're reading this, you are certainly looking to contribute to the code. Cucumber
is not this single repository. It is made up of several packages around several
repositories. So before going further with the code, you may consider the
following first, in order to get your bearings.

If you just want to know how to contribute to the code, go to
[Contribute to the code](#contribute-to-the-code).

If you want to report an issue, or suggest an enhancement, go to
[Report bugs and submit feature requests](#report-bugs-and-submit-feature-requests).

### Meet the community, the maintainers, and other Cucumber developers

Smartbear hosts a [community message board].
This is a good place to meet users, the community, and to ask questions.

You can also join the Cucumber Community Slack:
[register for an account][register-slack] then head over to [#intro][slack-intro].
This is the place to be to meet other contributors and find a mentor to help you
get started.

### Test Cucumber

Testing Cucumber, especially new features, is a great way to contribute. We
cannot put a price on (early) feedback.

Keep an eye on our CHANGELOGS to discover new features. Test and experiment, and
submit your feedback through [issues](#report-bugs-and-submit-feature-requests),
the [community message board], or [Slack][community-slack].

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
- Try to check there is not already an issue or pull request that deals with
  your bug or request
- Explain your issue and include as much details as possible to help other
  people reproduce your problem or understand your request
- Consider submitting a pull request if you feel confident enough

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

In any case, if your are not sure, best places to open an issue are the current
repository - `cucumber-ruby` - and the mono-repo at [cucumber/common].

### Look for existing issues and pull requests

Search in [the current repository][cucumber-ruby-issues], in the
[mono-repo][cucumber/common-issues], but also in the
[whole cucumber organization][cucumber-issues] if the problem or feature has already
been reported. If you find an issue or pull request which is still open, add
comments to it instead of opening a new one.

If you're not sure, don't hesitate to just open a new issue. We can always merge
and de-duplicate later.

### Submitting a pull request

When submitting a pull request:

- create a [draft pull request][how-to-create-a-draft-pr]
- try to follow the instructions in the [template](.github/PULL_REQUEST_TEMPLATE.md)
- if possible, [sign your commits]
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

If you request is for an enhancement - a new feature - try to be specific and
support your request with referenced facts and include examples to illustrate
your proposal.

## Contribute to the code

### Development environment

Development environment for `cucumber-ruby` is a simple Ruby environment with
Bundler. Use a [supported Ruby version](./README.md#supported-platforms), make
sure [Bundler] is set-up, and voilà!

You can then [fork][how-to-fork] and clone the repository. If your environment
is set-up properly, the following commands should install the dependencies and
execute all the tests successfully.

```shell
bundle install
bundle exec rake
```

You can now create a branch for your changes and [submit a pull request](#submitting-a-pull-request)!

If you want to check the code coverage during your development, execute
`bundle exec rake cov`.

### Cucumber-ruby-core

As seen here: [Find the appropriate repository](#find-the-appropriate-repository),
you may need to work with other repositories in order to accomplish your
development. Beside the mono-repo in [cucumber/common], [cucumber-ruby-core] is
also a big piece of `cucumber-ruby`.

### Using a local Gemfile

A local Gemfile allows you to use your prefer set of gems for your own
development workflow, like gems dedicated to debugging. Such gems are not part
of `cucumber-ruby` standard `Gemfile`.

`Gemfile.local`, `Gemfile.local.lock` and `.bundle` have been added to
`.gitignore` so local changes cannot be accidentaly commited and pushed to the
repository.

A `Gemfile.local` may look like this:

```ruby
# Gemfile.local

# Include the regular Gemfile
eval File.read('Gemfile')

# Include your favorites development gems
group :development do
  gem 'byebug'
  gem 'pry'
  gem 'pry-byebug'

  gem 'debase', require: false
  gem 'ruby-debug-ide', require: false
end
```

Then you can execute bundler with the `--gemfile` flag:
`bundle install --gemfile Gemfile.local`, or with an environment variable:
`BUNDLE_GEMFILE=Gemfile.local bundle [COMMAND]`.

To use your local Gemfile per default, you can also execute
`bundle config set --local gemfile Gemfile.local`.

### First timer? Welcome!

Looking for something simple to begin with? Look at issues with the label
'[good first issue](https://github.com/cucumber/cucumber-ruby/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22)'.

Remember: Cucumber is more than `cucumber-ruby`. You can look for good first
issues in [other cucumber reporistories](#find-the-appropriate-repository).

### Having trouble getting started with the code? We're here to help!

If you have trouble setting-up your development environment, or getting started
with the code, you can join us on [Slack][community-slack]. You will find there
a lot of contributors.

Full-time maintainers are also available. We would be please to have 1:1 pairing
sessions to help you getting started. Look for
[Matt Wynne](https://cucumberbdd.slack.com/team/U590XDLF3) or
[Aurélien Reeves](https://cucumberbdd.slack.com/team/U011BB95MC7) on
[Slack][community-slack].

### Additional documentation and notice

You can find additional documentation in the [docs](./docs) directory such as
(non-exhaustive list):

- [How to release cucumber-ruby](./docs/RELEASE_PROCESS.md) (for maintainers)
- [How to set-up a launch.json configuration for Visual Studio Code](./docs/vscode-example-launch-configuration.md)


<!-- Links -->

[community message board]: https://community.smartbear.com/t5/Cucumber-Open/bd-p/CucumberOS
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
[how-to-create-a-draft-pr]: https://docs.github.com/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests#draft-pull-requests
[how-to-fork]: https://docs.github.com/github/collaborating-with-pull-requests/working-with-forks/about-forks
[sign your commits]: https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/signing-commits
[minimal-reproducible-example]: https://stackoverflow.com/help/minimal-reproducible-example
[RVM]: https://rvm.io/
[rbenv]: https://github.com/rbenv/rbenv
[Bundler]: https://bundler.io/
