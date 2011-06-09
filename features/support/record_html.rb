if ENV['RECORD_HTML']

=begin

Builds a HTML representation of the files used in each scenario.
Source files get syntax highlighted with Pygments (http://pygments.org/ which now bundles https://github.com/cucumber/gherkin-pygments-lexer)
Cucumber output gets syntax highlighted with a2h (http://rtomayko.github.com/bcat/)

doc/scenarios/
└── features
    ├── hooks.feature:25
    │   ├── cucumber.cmd
    │   ├── cucumber.out.html
    │   └── features
    │       ├── f.feature.html
    │       ├── step_definitions
    │       │   └── steps.rb.html
    │       └── support
    │           └── hooks.rb.html
    └── hooks.feature:44
        ├── cucumber.cmd
        ├── cucumber.out.html
        └── features
            ├── f.feature.html
            ├── step_definitions
            │   └── steps.rb.html
            └── support
                └── hooks.rb.html

This can be post-processed to build a nice looking HTML page where users can "browse" example cucumber features and stepdefs - and see the output.

=end

require 'fileutils'
require 'bcat/ansi'

ENV['FORCE_COLOR'] = 'true'

module Pygments
  def pygmentize(dir, file)
    pygmentize = %{pygmentize -f html -O encoding=utf-8 "#{file}"}
    out = File.join(dir, file + '.html')
    FileUtils.mkdir_p(File.dirname(out)) unless File.directory?(File.dirname(out))
    `#{pygmentize} > #{out}`
  end
end
World(Pygments)

require 'aruba/api'
module Aruba::Api
  alias _run_simple run_simple
  def run_simple(cmd, fail_on_error=true)
    File.open(File.join(@_doc_dir, 'cucumber.cmd'), 'w') do |io|
      io.puts(cmd)
    end
    _run_simple(cmd, fail_on_error)
  end
end

Before do |scenario|
  @_doc_dir = File.expand_path("doc/scenarios/#{scenario.feature.file}:#{scenario.line}")
  if File.directory?(@_doc_dir)
    FileUtils.rm_rf(@_doc_dir)
  end
  FileUtils.mkdir_p(@_doc_dir)
end

After do |scenario|
  File.open(File.join(@_doc_dir, 'cucumber.out.html'), 'w') do |io|
    ansi = Bcat::ANSI.new(all_stdout_with_color)
    io.write(ansi.to_html)
  end
  in_current_dir do
    Dir['**/*'].select{|f| File.file?(f)}.each do |f|
      pygmentize(@_doc_dir, f)
    end
  end
end

end # if ENV['RECORD_HTML']
