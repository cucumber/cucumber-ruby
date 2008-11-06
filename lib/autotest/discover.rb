Autotest.add_discovery do
  "cucumber" if ENV['AUTOFEATURE'] == 'true' && File.directory?('features')
end
