desc 'Make all files use UNIX (\n) line endings'
task :fix_cr_lf do
  files = FileList['**/*']
  $\="\n"
  files.each do |f|
    raw_content = File.read(f)
    fixed_content = ""
    raw_content.each_line do |line|
      fixed_content << line
    end
    unless raw_content == fixed_content
      File.open(f, "w") do |io|
        io.print fixed_content
      end
    end
  end
end