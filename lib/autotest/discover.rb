Autotest.add_discovery do
  if File.directory?('features')
    if ENV['AUTOFEATURE'] =~ /true/i
      "cucumber"
    elsif ENV['AUTOFEATURE'] =~ /false/i
    else
      puts "(Not running features.  To run features in autotest, set AUTOFEATURE=true.)"
    end
  end
end
