= stories

* FIX http://rspec.info/stories

== DESCRIPTION:

This code parses RSpec stories. It uses a Treetop grammar to do the job, and 
this grammar is extended by users of the library. This design makes the code
very compact, and it makes it easy to give precise line and column info on 
parse errors. Further, when a step fails, the story file will appear in the
stack trace, along with regular ruby files.

== FEATURES/PROBLEMS:

* TODO: Add a yaml file for different languages
* TODO: Custom nodes for the syntax tree
* TODO: Actually execute the stories
* TODO: Make rake run specs by default

== SYNOPSIS:

  FIX (code sample of usage)

== REQUIREMENTS:

* gem install treetop

== INSTALL:

* gem install stories

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