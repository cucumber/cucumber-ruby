# Upgrading to 8.0.0

## The wire protocol

Usage of built-in wire protocol with `cucumber-ruby` will be deprecated in cucumber
8.0.0, and removed in cucumber 9.0.0.

The wire protocol will still be available by explicitely using the `cucumber-wire`
gem.

### Before cucumber 8.0.0

Before cucumber 8.0.0, the wire protocol was automatically installed with cucumber,
and automatically activated when it had detected a `.wire` file.

### With cucumber 8.0.0

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

## Usage of AfterConfiguration hook

The AfterConfiguration hook has a new parameter: `registry`. It is an instance of
`Cucumber::Glue::RegistryWrapper` that wraps some methods of the registry that has
been instantiated for the `runtime`'s support code.

### Before cucumber 8.0.0

```ruby
AfterConfiguration do |config|
  # your code here
end
```

### With cucumber 8.0.0

```ruby
AfterConfiguration do |config, registry|
  # your code here
end
```
