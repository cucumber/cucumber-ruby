# frozen_string_literal: true

desc 'Run all examples'
task :examples do
  Dir['examples/*'].each do |example_dir|
    next if !File.directory?(example_dir) || %w[examples/tcl].index(example_dir)

    puts "Running #{example_dir}"
    Dir.chdir(example_dir) do
      raise "No Rakefile in #{Dir.pwd}" unless File.file?('Rakefile')

      sh 'rake cucumber'
    end
  end
end
