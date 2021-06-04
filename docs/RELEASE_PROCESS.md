# Release process for cucumber-ruby

## Prerequisites

To release `cucumber-ruby`, you'll need:

- to be a member of the core-team
- make
- docker

## cucumber-ruby-core and cucumber-ruby-wire

If internal libraries such as `cucumber-gherkin` needs to be updated, you'll
need to update and release `cucumber-ruby-core` first, then `cucumber-ruby-wire`.

## Releasing cucumber-ruby

- Upgrade gems with `scripts/update-gemspec`
- Bump the version number in `lib/cucumber/version`
- Update `CHANGELOG.md` with the upcoming version number and create a new `In Git` section
- Remove empty sections from `CHANGELOG.md`
- Commit the changes using a verified signature
  ```shell
  git commit --gpg-sign -am "Release X.Y.Z"
  ```
- Now release it:
  ```shell
  make release
  ```
- Check the release has been successfully pushed to [rubygems](https://rubygems.org/gems/cucumber)
- Finally, update the `cucumber-ruby` version in the
  [documentation project](https://cucumber.io/docs/installation/) in
  [versions.yaml](https://github.com/cucumber/docs/blob/master/data/versions.yaml).
