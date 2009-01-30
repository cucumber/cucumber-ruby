namespace :gemspec do
  desc 'Refresh cucumber.gemspec to include ALL files'
  task :refresh => 'manifest:refresh' do
    File.open('cucumber.gemspec', 'w') {|io| io.write($hoe.spec.to_ruby)}
    puts "1) git commit -a -m \"Release #{Cucumber::VERSION::STRING}\""
    puts "2) git tag -a \"v#{Cucumber::VERSION::STRING}\" -m \"Release #{Cucumber::VERSION::STRING}\""
    puts "3) git push"
    puts "4) git push --tags"
  end
end