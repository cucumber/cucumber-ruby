## Pre-requisites

### Ruby Extension

Install and configure the
[ruby extension](https://marketplace.visualstudio.com/items?itemName=rebornix.Ruby)

### Use `debase` and `ruby-debug-ide` gems locally

Make sure to use a `Gemfile.local` file with `debase` and `ruby-debug-ide` gems.

~~~ruby
# Include the regular Gemfile
eval File.read('Gemfile')

group :development do
  gem 'debase', require: false
  gem 'ruby-debug-ide', require: false
end 
~~~

Execute `bundle config set --local gemfile Gemfile.local` to use it per default,
then `bundle install`.

## Sample launch.json

The following `launch.json` - to be placed in the `.vscode` folder - allows to use
VSCode debugging features like **breakpoints** and **watches**. It contains 3 configurations:

- `Cucumber` is equivalent to `bundle exec cucumber`
- `Cucumber current feature file` will execute cucumber 
  over the currently opened file: it must be a `.feature` file
- `Cucumber scenario under cursor` will execute cucumber over the scenario under the cursor. 
  Caution: the cursor MUST be on the line of the name of the scenario. Refs: [#1469]

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Cucumber",
            "type": "Ruby",
            "request": "launch",
            "useBundler": true,
            "program": "${workspaceRoot}/bin/cucumber",
            "internalConsoleOptions": "openOnSessionStart"
        },
        {
            "name": "Cucumber current feature file",
            "type": "Ruby",
            "request": "launch",
            "useBundler": true,
            "program": "${workspaceRoot}/bin/cucumber",
            "args": ["${file}"],
            "internalConsoleOptions": "openOnSessionStart"
        },
        {
            "name": "Cucumber scenario under cursor",
            "type": "Ruby",
            "request": "launch",
            "useBundler": true,
            "program": "${workspaceRoot}/bin/cucumber",
            "args": ["${file}:${lineNumber}"],
            "internalConsoleOptions": "openOnSessionStart"
        }
    ]
}
```