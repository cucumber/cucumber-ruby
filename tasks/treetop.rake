namespace :treetop do
  desc 'Compile the grammar'
  task :compile do
    system "tt.bat lib/cucumber/story.treetop.erb -o lib/cucumber/story_parser.rb"
  end
  
  # http://groups.google.com/group/treetop-dev/browse_thread/thread/c8a8ced33da07f73
  # http://github.com/vic/treetop/commit/5cec030a1c363e06783f98e4b45ce6ab121996ab
  desc 'Fix compiled grammar'
  task :fix => :compile do
    parser = IO.read 'lib/cucumber/story_parser.rb'
    File.open('lib/cucumber/story_parser.rb', 'w') do |io|
      io.puts "module Cucumber"
      io.puts parser
      io.puts "end"
    end
  end
end