# Please do not add to the tests in this folder

This folder contains the acceptance tests that were written for Cucumber
before [Aruba](https://github.com/cucumber/aruba) existed.

These tests are currently run as part of the build, but should not be added to.

New acceptance tests should be added in the `features` directory. If you find a test
in here that you want to modify, please do the work to migrate it into the `features`
directory.

There is a ticket [#408](https://github.com/cucumber/cucumber/issues/408) to track 
the effort to migrate all these tests into the `features` directory. We aim to have this
completed for the release of Cucumber 2.0
