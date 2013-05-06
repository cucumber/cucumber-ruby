Given(/^a Gemfile with:$/) do |content|
  path = File.expand_path(current_dir + "/Gemfile")
  write_file path, content
  set_env "BUNDLE_GEMFILE", path
end
