class FeatureCompiler
  def compile
    require 'yaml'
    require 'erb'
    tt = PLATFORM =~ /win32/ ? 'tt.bat' : 'tt'

    template = ERB.new(IO.read(File.dirname(__FILE__) + '/../lib/cucumber/treetop_parser/feature.treetop.erb'))
    langs = YAML.load_file(File.dirname(__FILE__) + '/../lib/cucumber/languages.yml')

    langs.each do |lang, words|
      grammar_file = File.dirname(__FILE__) + "/../lib/cucumber/treetop_parser/feature_#{lang}.treetop"
      grammar = template.result(binding)
      File.open(grammar_file, "wb") do |io|
        io.write(grammar)
      end
      sh "#{tt} #{grammar_file}"
      FileUtils.rm(grammar_file)
    end
  end
end

namespace :treetop do
  desc 'Compile the grammar for all languages in languages.yml'
  task :compile do
    FeatureCompiler.new.compile
  end
end