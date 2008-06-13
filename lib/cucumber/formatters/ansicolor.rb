require 'term/ansicolor'
begin
  require 'Win32/Console/ANSI' if PLATFORM =~ /mswin|mingw/
rescue LoadError
  STDERR.puts "You must gem install win32console to get coloured output on this ruby platform (#{PLATFORM})"
  ::Term::ANSIColor.coloring = false
end
::Term::ANSIColor.coloring = false if PLATFORM =~ /java/

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
      alias skipped blue
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