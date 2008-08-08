namespace :gemspec do
  desc 'Refresh cucumber.gemspec to include ALL files'
  task :refresh => 'manifest:refresh' do
    File.open('cucumber.gemspec', 'w') {|io| io.write($hoe.spec.to_ruby)}
  end
end