# frozen_string_literal: true

Autotest.add_discovery do
  if File.directory?('features')
    case ENV['AUTOFEATURE']
    when /true/i
      'cucumber'
    when /false/i
      # noop
    else
      puts '(Not running features.  To run features in autotest, set AUTOFEATURE=true.)'
    end
  end
end
