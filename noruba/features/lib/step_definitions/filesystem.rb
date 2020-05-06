def mkdir_p(path)
  complete_path = '.'
  path.split(/\/|\\/).each do |folder|
    complete_path = File.join(complete_path, folder)
    FileUtils.mkdir(complete_path) unless Dir.exist?(complete_path)
  end
end

def write_file(path, content)
  mkdir_p(File.dirname(path))
  File.open(path, 'w') { |file| file.write(content) }
end