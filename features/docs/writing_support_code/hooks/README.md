# Cucumber Hooks

Cucumber proposes several hooks to let you specify some code to be executed at
different stage of the test execution, like before or after the execution of a
scenario.

They are executed in the following order:

- AfterConfiguration
- InstallPlugin
- BeforeAll
  - Per scenario:
    - Around
    - Before
      - Per step:
        - AfterStep
    - After
- AfterAll

You can define as many hooks as you want. If you have several hooks of the same
types - for example, several BeforeAll hooks - they will be all executed once.

## AfterConfiguration and InstallPlugin

AfterConfiguration and InstallPlugin hooks are dedicated to plugins and are meant
to extend Cucumber. For example, AfterConfiguration allows you to dynamically
change the configuration before the execution of the tests. InstallPlugin allows
to have some code that would have deep impact on the execution.

### AfterConfiguration

Note: this is a legacy hook. You may consider using InstallPlugin instead.

```ruby
AfterConfiguration do |configuration|
  # configuration is an instance of Cucumber::Configuration defined in
  # lib/cucumber/configuration.rb.
end
```

### InstallPlugin

In addition of the configuration, IntallPlugin also has access to some of Cucumber
internals through a RegistryWrapper, defined in lib/cucumber/glue/registry_wrapper.rb.

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

BeforeAll is executed once before the execution of the first scenario. AfterAll
is executed once after the execution of the last scenario.

They do not have parameters. Their purpose is to set-up or clean-up your environment
which is not related to Cucumber, like a database, a browser, or the subject under test.

```ruby
BeforeAll do
  # snip
end

AfterAll do
  # snip
end
```

## Around

Note: Around is a legacy hook and its usage is discouraged in favor of Before and
After hooks.

Around is a special hook which allows you to have a block syntax. Its original purpose
was to support some databases which provide only block syntax for transactions.

```ruby
Around do |scenario, block|
  block.call
end
```

## Before and After

Before is executed before each scenario. After is executed after each scenario.
They both have the scenario being executed. In the After hook, the scenario status
is also available.

```ruby
Before do |scenario|
  log scenario.name
end

After do |scenario|
  log scenario.failed?
  log scenario.status
end
```

## AfterStep

AfterStep is executed after each step of a test.

```ruby
AfterStep do |result, test_step|
  log result.inspect # result is a Cucumber::Core::Test::Result
  log test_step.inspect # test_step is a Cucumber::Core::Test::Step
end
```
