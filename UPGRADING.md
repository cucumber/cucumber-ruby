# Upgrading to 8.0.0

## `Cucumber::Cli::Main` former `stdin` argument

The second argument of `Cucumber::Cli::Main` - which was formerly named `stdin` -
has been removed.

### Before cucumber 8.0.0

You would have used `Cucumber::Cli::Main` with a dummy parameter:

```ruby
Cucumber::Cli::Main.new(
      argument_list,
      nil, # <-- this is a former unused `stdin` parameter
      @stdout,
      @stderr,
      @kernel
).execute!
```

### With cucumber 8.0.0

The argument has been removed from the initializer so the dummy parameter is not
required anymore:

```ruby
Cucumber::Cli::Main.new(
      argument_list,
      @stdout,
      @stderr,
      @kernel
).execute!
```

# Upgrading to 7.1.0

## The wire protocol

Usage of built-in wire protocol with `cucumber-ruby` will be deprecated in cucumber
7.1.0, and removed in cucumber 8.0.0.

The wire protocol will still be available by explicitely using the `cucumber-wire`
gem.

### Before cucumber 7.1.0

Before cucumber 7.1.0, the wire protocol was automatically installed with cucumber,
and automatically activated when it had detected a `.wire` file.

### With cucumber 7.1.0

The wire protocol will work as before, but you will notice a deprecation message.

To prevent the deprecation message to be shown, add the gem `cucumber-wire` to your
Gemfile alongside the `cucumber` one, and install it:

```ruby
# Gemfile

# ...

gem "cucumber"
gem "cucumber-wire"

# ...

```
```shell
bundle install
```

And add `require 'cucumber/wire'` in your support code. If you do not have support
code yet, create a new one. For example `features/support/wire.rb`.

```ruby
# features/support/wire.rb
require 'cucumber/wire'
```

The wire protocol will be installed, and no deprecation message will be shown anymore.

## AfterConfiguration hook

Usage of `AfterConfiguration` hook will be deprecated in 7.1.0.

Use the new `InstallPlugin` hook if you need the `configuration` parameter.

Use the new `BeforeAll` hook if you don't need the `configuration` parameter.

More information about hooks can be found in [features/docs/writing_support_code/hooks/README.md](./features/docs/writing_support_code/hooks/README.md).
