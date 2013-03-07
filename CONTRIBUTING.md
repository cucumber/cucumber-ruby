# Contributing to Cucumber

This document is a guide for those maintaining Cucumber, and others who would like to submit patches.

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

## Release Process

Before you even attempt to do a release, make sure you can log into cukes.info and touch a file in /var/www/cucumber/api/ruby (see gem_tasks/yard.rake). You need to be able to do this in order to upload YARD docs as part of the release.

* Bump the version number in `lib/cucumber/platform.rb`.
* Make sure `History.md` is updated with the upcoming version number, and has entries for all fixes.
* No need to add a `History.md` header at this point - this should be done when a new change is made, later.
* Make sure you have up-to-date and clean copy of cucumber/cucumber.github.com.git at the same level as cucumber repo

Now release it

    bundle update
    bundle exec rake
    git commit -m "Release X.Y.Z"
    rake release

## Gaining Release Karma

To become a release manager, create a pull request adding your name to the list below, and include your Rubygems email address in the ticket. One of the existing Release managers will then add you.

Current release managers:
  * Matt Wynne
  * Aslak Hellesøy
  * Oleg Sukhodolsky

To grant release karma, issue the following command:

    gem owner cucumber --add <NEW OWNER RUBYGEMS EMAIL>
