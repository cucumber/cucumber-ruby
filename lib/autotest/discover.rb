Autotest.add_discovery do
  "cucumber" if File.directory?('features')
end
