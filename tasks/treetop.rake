desc 'Compile the grammar'
task :compile_grammar do
  system "tt lib/cucumber/story.treetop.erb -o lib/cucumber/story_parser.rb"
end