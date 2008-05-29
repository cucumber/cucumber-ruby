class StoryCompiler
  def compile
    require 'yaml'
    require 'erb'
    tt = PLATFORM =~ /win32/ ? 'tt.bat' : 'tt'
    template = ERB.new(IO.read(File.dirname(__FILE__) + '/../lib/cucumber/parser/story_parser.treetop.erb'))
    langs = YAML.load_file(File.dirname(__FILE__) + '/../lib/cucumber/parser/languages.yml')
    langs.each do |lang, words|
      grammar_file = File.dirname(__FILE__) + "/../lib/cucumber/parser/story_parser_#{lang}.treetop"

      STDOUT.write("Generating and compiling grammar for #{lang}...")
      grammar = template.result(binding)
      
      # http://groups.google.com/group/treetop-dev/browse_thread/thread/c8a8ced33da07f73
      # http://github.com/vic/treetop/commit/5cec030a1c363e06783f98e4b45ce6ab121996ab
      grammar = "module Cucumber\nmodule Parser\n#{grammar}\nend\nend"
      
      File.open(grammar_file, "wb") do |io|
        io.write(grammar)
      end
      system "#{tt} #{grammar_file}"
      FileUtils.rm(grammar_file)
      STDOUT.puts("Done!")
    end
  end
end

namespace :treetop do
  desc 'Compile the grammar'
  task :compile do
    StoryCompiler.new.compile
  end
end