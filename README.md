The main website is at http://cukes.info/
The documentation is at https://wiki.github.com/cucumber/cucumber/

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile, version, or history.
  (if you want to have your own version, that is fine but
  bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Running tests

    gem install bundler
    bundle install
    git submodule update --init --recursive
    rake

## Release Process

* Bump the version number in `lib/cucumber/platform.rb`.
* Make sure `History.md` is updated with the upcoming version number, and has entries for all fixes.


    bundle update
    rake
    git commit -m "Release X.Y.Z"
    rake release

## Copyright

Copyright (c) 2008,2009,2010,2011 Aslak Hellesøy and Contributors. See LICENSE for details.

