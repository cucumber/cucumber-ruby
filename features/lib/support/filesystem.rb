# frozen_string_literal: true

def write_file(path, content)
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, 'w') { |file| file.write(content) }
end

def copy_image_named(name)
  fixture_dir = File.expand_path('../../features/docs/fixtures')
  FileUtils.cp("#{fixture_dir}/#{name}", "#{Dir.pwd}/features/#{name}")
end
