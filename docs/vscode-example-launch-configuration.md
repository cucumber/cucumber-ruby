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
VSCode debugging features like **breakpoints** and **watches**. 

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Cucumber",
            "type": "Ruby",
            "request": "launch",
            "useBundler": true,
            "cwd": "${workspaceRoot}",
            "program": "${workspaceRoot}/bin/cucumber",
            "internalConsoleOptions": "openOnSessionStart"
        },
        {
            "name": "Cucumber current feature file",
            "type": "Ruby",
            "request": "launch",
            "useBundler": true,
            "cwd": "${workspaceRoot}",
            "program": "${workspaceRoot}/bin/cucumber",
            "args": ["${file}"],
            "internalConsoleOptions": "openOnSessionStart"
        },
        {
            "name": "Cucumber scenario under cursor",
            "type": "Ruby",
            "request": "launch",
            "useBundler": true,
            "cwd": "${workspaceRoot}",
            "program": "${workspaceRoot}/bin/cucumber",
            "args": ["${file}:${lineNumber}"],
            "internalConsoleOptions": "openOnSessionStart"
        },
        {
            "name": "Rspec",
            "type": "Ruby",
            "request": "launch",
            "useBundler": true,
            "cwd": "${workspaceRoot}",
            "program": "${workspaceRoot}/bin/rspec",
            "internalConsoleOptions": "openOnSessionStart"
        },
        {
            "name": "Rspec current file",
            "type": "Ruby",
            "request": "launch",
            "useBundler": true,
            "cwd": "${workspaceRoot}",
            "program": "${workspaceRoot}/bin/rspec",
            "args": ["${file}"],
            "internalConsoleOptions": "openOnSessionStart"
        },
        {
            "name": "Rspec current line",
            "type": "Ruby",
            "request": "launch",
            "useBundler": true,
            "cwd": "${workspaceRoot}",
            "program": "${workspaceRoot}/bin/rspec",
            "args": ["${file}:${lineNumber}"],
            "internalConsoleOptions": "openOnSessionStart"
        }
    ]
}
```