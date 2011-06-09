if ENV['RECORD_HTML']

=begin

Builds a HTML representation of the files used in each scenario.
Source files get syntax highlighted with Pygments (http://pygments.org/ which now bundles https://github.com/cucumber/gherkin-pygments-lexer)
Cucumber output gets syntax highlighted with a2h (http://rtomayko.github.com/bcat/)

doc/scenarios/features
|-- hooks.feature:25
|   |-- cucumber.out
|   `-- features
|       |-- f.feature.html
|       |-- step_definitions
|       |   `-- steps.rb.html
|       `-- support
|           `-- hooks.rb.html
`-- hooks.feature:44
    |-- cucumber.out
    `-- features
        |-- f.feature.html
        |-- step_definitions
        |   `-- steps.rb.html
        `-- support
            `-- hooks.rb.html

This can be post-processed to build a nice looking HTML page where users can "browse" example cucumber features and stepdefs - and see the output.

=end

require 'fileutils'

module Pygments
  def pygmentize(dir, file)
    pygmentize = %{pygmentize -f html -O encoding=utf-8 "#{file}"}
    out = File.join(dir, file + '.html')
    FileUtils.mkdir_p(File.dirname(out)) unless File.directory?(File.dirname(out))
    `#{pygmentize} > #{out}`
  end
end
World(Pygments)

Before do |scenario|
  @_doc_dir = File.expand_path("doc/scenarios/#{scenario.feature.file}:#{scenario.line}")
  if File.directory?(@_doc_dir)
    FileUtils.rm_rf(@_doc_dir)
  end
  FileUtils.mkdir_p(@_doc_dir)
end

After do |scenario|
  File.open(File.join(@_doc_dir, 'cucumber.out'), 'w') do |io|
    io.write(all_stdout) # TODO: Make Aruba output colours and pass through a2h
  end
  in_current_dir do
    Dir['**/*'].select{|f| File.file?(f)}.each do |f|
      pygmentize(@_doc_dir, f)
    end
  end
end

end # if ENV['RECORD_HTML']
