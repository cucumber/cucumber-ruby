require 'term/ansicolor'
begin
  require 'Win32/Console/ANSI' if PLATFORM =~ /win32/
rescue LoadError
  raise 'You must gem install win32console to use color on Windows'
end

module Cucumber
  module Formatters
    # Adds ANSI color support to formatters.
    # You can define CUCUMBER_COLORS in your shell. Example:
    #
    #   CUCUMBER_COLORS="passed=blue:failed=magenta"
    # 
    # You can use all the colours available in term-ansicolors:
    #
    #   ruby -e "require 'rubygems'; require 'term/ansicolor'; puts Term::ANSIColor::ATTRIBUTE_NAMES"
    #
    module ANSIColor
      include ::Term::ANSIColor

      # Default aliases
      alias passed green
      alias failed red
      alias pending yellow
      alias skipped black
      alias parameter underline
      
      if ENV['CUCUMBER_COLORS']
        ENV['CUCUMBER_COLORS'].split(':').each do |pair|
          a = pair.split('=')
          eval "alias #{a[0]} #{a[1]}"
        end
      end
    end
  end
end