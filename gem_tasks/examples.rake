desc 'Run all exmples'
task :examples do
  Dir['examples/*'].each do |example_dir|
    next if !File.directory?(example_dir) || %w{fixtures/junit examples/i18n examples/python examples/ruby2python fixtures/self_test examples/steps_library examples/tickets}.index(example_dir)
    puts "Running #{example_dir}"
    Dir.chdir(example_dir) do
      sh "rake cucumber"
    end
  end
end