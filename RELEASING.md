# Release process for cucumber-ruby

## Prerequisites

To release `cucumber-ruby`, you'll need:

- to be a member of the core-team
- make
- docker

## cucumber-ruby-core

If internal libraries such as `cucumber-gherkin` needs to be updated, you'll
need to update and release `cucumber-ruby-core` before releasing `cucumber-ruby`.

## Releasing cucumber-ruby

- Upgrade gems with `scripts/update-gemspec`
- Bump the version number in `lib/cucumber/version`
- Update `CHANGELOG.md` with the upcoming version number and create a new `Unreleased` section
- Remove empty sections from `CHANGELOG.md`
- Commit the changes using a verified signature
  ```shell
  git commit --gpg-sign -am "Release X.Y.Z"
  git push
  ```
- Now release it: push to a dedicated `release/` branch:
  ```shell
  git push origin main:release/vX.Y.Z
  ```
- Check the release has been successfully pushed to [rubygems](https://rubygems.org/gems/cucumber)
- Finally, update the `cucumber-ruby` version in the
  [documentation project](https://cucumber.io/docs/installation/) in
  [versions.yaml](https://github.com/cucumber/docs/blob/master/data/versions.yaml).
