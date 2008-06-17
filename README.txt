= cucumber

* FIX http://rspec.info/cucumber

== DESCRIPTION:

This code parses RSpec stories. It uses a Treetop grammar to do the job, and 
this grammar is extended by users of the library. This design makes the code
very compact, and it makes it easy to give precise line and column info on 
parse errors. Further, when a step fails, the story file will appear in the
stack trace, along with regular ruby files.

== FEATURES/PROBLEMS:

* Run examples with:
** ruby -Ilib bin/cucumber examples/simple --require examples/simple/steps
** ruby -Ilib bin/cucumber examples/web --require examples/web/steps

* TODO: OK Refactor: Extract explicit node classes with RDoc (for better API doc)
* TODO: OK Get rid of the compile method. Compile the parser in Rake.
* TODO: OK Make grammar support \r\n, \r and \n (Add some fixture stories for that) 
* TODO: OK Make grammar support indentation
* TODO: OK Make grammar be totally relaxed about narrative
* TODO: OK Add a yaml file for different languages
* TODO: OK Custom nodes for the syntax tree
* TODO: OK Actually execute the stories
* TODO: Make rake run specs by default
* TODO: OK Make it work with pure ruby regexen
* TODO: Make it work with strings
* TODO: bin/cucumber --require [dir|file|glob]* --language no --format [file]*
* TODO: Pending steps shold print a block of code that can be pasted into code
* TODO: cucumber --where "Some text from a step" that prints "__FILE__:__LINE__ (STEP PATTERN)" 
* TODO: Customisable trace output (like javascriptlint)
* TODO: Experiment: Make $variables become @variables
* TODO: GivenScenario
* TODO: PureRuby
  * Make two trees include accept mixin
* TODO: Call steps from steps
* TODO: i18n in ruby too
* TODO: Don't load any treetop files if no .story files are found

== SYNOPSIS:

  FIX (code sample of usage)

== REQUIREMENTS:

* gem install treetop

== INSTALL:

* gem install cucumber

== LICENSE:

(The MIT License)

Copyright (c) 2008 Aslak Hellesøy

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.