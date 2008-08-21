require 'term/ansicolor'
begin
  require 'Win32/Console/ANSI' if PLATFORM =~ /mswin|mingw/
rescue LoadError
  STDERR.puts "You must gem install win32console to get coloured output on this ruby platform (#{PLATFORM})"
  ::Term::ANSIColor.coloring = false
end
::Term::ANSIColor.coloring = false if !STDOUT.tty?

module Cucumber
  module Formatters
    # Adds ANSI color support to formatters.
    # You can define your own colours by defining CUCUMBER_COLORS in your shell. Example:
    #
    #   CUCUMBER_COLORS=pending=black,on_yellow:failed=dark,magenta:failed_param=bold,red
    # 
    # The string must be a series of key=value pairs where:
    #
    #   * Each key=value pair is separated by a colon (:)
    #   * Each key must be one of:
    #   ** passed
    #   ** passed_param
    #   ** failed
    #   ** failed_param
    #   ** skipped
    #   ** skipped_param
    #   ** pending
    #   * Each value must be a comma-separated string composed of:
    #   ** bold
    #   ** dark
    #   ** italic
    #   ** underline
    #   ** underscore
    #   ** blink
    #   ** rapid_blink
    #   ** negative
    #   ** concealed
    #   ** strikethrough
    #   ** black
    #   ** red
    #   ** green
    #   ** yellow
    #   ** blue
    #   ** magenta
    #   ** cyan
    #   ** white
    #   ** on_black
    #   ** on_red
    #   ** on_green
    #   ** on_yellow
    #   ** on_blue
    #   ** on_magenta
    #   ** on_cyan
    #   ** on_white
    #
    module ANSIColor
      include ::Term::ANSIColor

      # Params are underlined bold, except in windows, which doesn't support underline. Use non-bold colour.
      param = PLATFORM =~ /mswin|mingw/ ? '' : 'underline,bold,'

      # Default aliases
      ALIASES = {
        :passed        => 'bold,green',
        :passed_param  => "#{param}green",
        :failed        => 'bold,red',
        :failed_param  => "#{param}red",
        :skipped       => 'bold,cyan',
        :skipped_param => "#{param}cyan",
        :pending       => 'bold,yellow' # No pending_param
      }
      if ENV['CUCUMBER_COLORS']
        ENV['CUCUMBER_COLORS'].split(':').each do |pair|
          a = pair.split('=')
          ALIASES[a[0].to_sym] = a[1]
        end
      end
      
      ALIASES.each do |m, color_string|
        colors = color_string.split(",").reverse
        define_method(m) do |*s|
          ::Term::ANSIColor.coloring = false if ENV['CUCUMBER_COLORS_DISABLED'] == '1'
          clear + colors.inject(s[0]) do |memo, color|
            s[0].nil? ? __send__(color) + memo.to_s : __send__(color, memo.to_s)
          end
        end
      end
    end
  end
end