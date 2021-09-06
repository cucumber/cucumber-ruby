# Cucumber Hooks

Cucumber proposes several hooks to let you specify some code to be executed at
different stages of test execution, like before or after the execution of a
scenario.

Hooks are part of your support code.

They are executed in the following order:

- [AfterConfiguration](#afterconfiguration-and-installplugin)
- [InstallPlugin](#afterconfiguration-and-installplugin)
- [BeforeAll](#beforeall-and-afterall)
  - Per scenario:
    - [Around](#around)
    - [Before](#before-and-after)
      - Per step:
        - [AfterStep](#afterstep)
    - [After](#before-and-after)
- [AfterAll](#beforeall-and-afterall)

You can define as many hooks as you want. If you have several hooks of the same
types - for example, several `BeforeAll` hooks - they will be all executed once.

Multiple hooks of the same type are executed in the order that they were defined.
If you wish to control this order, use manual requires in `env.rb` - This file is
loaded first - or migrate them all to one `hooks.rb` file.

## AfterConfiguration and InstallPlugin

[`AfterConfiguration`](#afterconfiguration) and [`InstallPlugin`](#installplugin)
hooks are dedicated to plugins and are meant to extend Cucumber. For example,
[`AfterConfiguration`](#afterconfiguration) allows you to dynamically change the
configuration before the execution of the tests, and [`InstallPlugin`](#installplugin)
allows to have some code that would have deeper impact on the execution.

### AfterConfiguration

**Note:** this is a legacy hook. You may consider using [`InstallPlugin`](#installplugin) instead.

```ruby
AfterConfiguration do |configuration|
  # configuration is an instance of Cucumber::Configuration defined in
  # lib/cucumber/configuration.rb.
end
```

### InstallPlugin

In addition to the configuration, `IntallPlugin` also has access to some of Cucumber
internals through a `RegistryWrapper`, defined in
[lib/cucumber/glue/registry_wrapper.rb](../../../../lib/cucumber/glue/registry_wrapper.rb).

```ruby
InstallPlugin do |configuration, registry|
  # configuration is an instance of Cucumber::Configuration defined in
  # lib/cucumber/configuration.rb
  #
  # registry is an instance of Cucumber::Glue::RegistryWrapper defined in
  # lib/cucumber/glue/registry_wrapper.rb
end
```

You can see an example in the [Cucumber Wire plugin](https://github.com/cucumber/cucumber-ruby-wire).

## BeforeAll and AfterAll

`BeforeAll` is executed once before the execution of the first scenario. `AfterAll`
is executed once after the execution of the last scenario.

These two types of hooks have no parameters. Their purpose is to set-up and/or clean-up
your environment not related to Cucumber, like a database or a browser.

```ruby
BeforeAll do
  # snip
end

AfterAll do
  # snip
end
```

## Around

**Note:** `Around` is a legacy hook and its usage is discouraged in favor of
[`Before` and `After`](#before-and-after) hooks.

`Around` is a special hook which allows you to have a block syntax. Its original
purpose was to support some databases with only block syntax for transactions.

```ruby
Around do |scenario, block|
  SomeDatabase::begin_transaction do # this is just for illustration
    block.call
  end
end
```

## Before and After

`Before` is executed before each test case. `After` is executed after each test case.
They both have the test case being executed as a parameter. Within the `After` hook,
the status of the test case is also available.

```ruby
Before do |test_case|
  log test_case.name
end

After do |test_case|
  log test_case.failed?
  log test_case.status
end
```

## AfterStep

`AfterStep` is executed after each step of a test. If steps are not executed due
to a previous failure, `AfterStep` won't be executed either.

```ruby
AfterStep do |result, test_step|
  log test_step.inspect # test_step is a Cucumber::Core::Test::Step
  log result.inspect # result is a Cucumber::Core::Test::Result
end
```
