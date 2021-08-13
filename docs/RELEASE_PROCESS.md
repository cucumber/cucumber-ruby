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
- Update `CHANGELOG.md` with the upcoming version number and create a new `Unreleased` section at the top
- Commit the changes:
  ```shell
  git commit -am "Release X.Y.Z"
  git push
  ```

This will trigger the `[pre-release](../.github/workflows/pre-release.yaml)` workflow which will create a pull request to a new `release/vX.Y.Z` branch.

Once that PR is merged by a member of the `[@cucumber/cucumber-ruby](https://github.com/orgs/cucumber/teams/cucumber-ruby)` team, the `[release](../.github/workflows/release.yaml)` workflow will kick in and release the new version of the gem.

Once the PR has been merged:

- Check the release has been successfully pushed to [rubygems](https://rubygems.org/gems/cucumber)
- Finally, update the `cucumber-ruby` version in the
  [documentation project](https://cucumber.io/docs/installation/) in
  [versions.yaml](https://github.com/cucumber/docs/blob/master/data/versions.yaml).
