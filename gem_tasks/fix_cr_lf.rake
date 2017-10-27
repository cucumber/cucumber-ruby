# frozen_string_literal: true

require 'pathname'

desc 'Make all files use UNIX (\n) line endings'
task :fix_cr_lf do
  iso_8859_1_files = FileList.new(
    'features/docs/iso-8859-1.feature',
    'features/lib/step_definitions/iso-8859-1_steps.rb'
  )

  utf8_files = FileList.new('**/*') do |fl|
    fl.exclude { |f| File.directory?(f) }
  end

  paths = (utf8_files - iso_8859_1_files).map { |f| Pathname(f) }

  paths.each do |path|
    content = path.read.gsub(/\r?\n/, "\n")
    path.write(content)
  end
end
