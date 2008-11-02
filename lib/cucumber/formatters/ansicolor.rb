gem 'term-ansicolor'
# Hack to work around Win32/Console, which bundles a licence-violating, outdated
# copy of term/ansicolor that doesn't implement Term::ANSIColor#coloring=. 
# We want the official one!
$LOAD_PATH.each{|path| $LOAD_PATH.unshift($LOAD_PATH.delete(path)) if path =~ /term-ansicolor/}

require 'term/ansicolor'
require 'rbconfig'

win = Config::CONFIG['host_os'] =~ /mswin|mingw/
jruby = defined?(JRUBY_VERSION)

begin
  require 'Win32/Console/ANSI' if (win && !jruby)
rescue LoadError
  STDERR.puts "You must gem install win32console to get coloured output on this ruby platform (#{PLATFORM})"
  ::Term::ANSIColor.coloring = false
end
::Term::ANSIColor.coloring = false if !STDOUT.tty? || (win && jruby)

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
    #   ** grey
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
        :pending       => 'bold,yellow', # No pending_param
        :comment       => 'grey'
      }
      if ENV['CUCUMBER_COLORS']
        ENV['CUCUMBER_COLORS'].split(':').each do |pair|
          a = pair.split('=')
          ALIASES[a[0].to_sym] = a[1]
        end
      end
      
      #Not supported in Term::ANSIColor
      def grey(m)
        if ::Term::ANSIColor.coloring?
          "\e[90m#{m}\e[0m" 
        else
          m
        end
      end
      
      ALIASES.each do |m, color_string|
        colors = color_string.split(",").reverse
        define_method(m) do |*s|
          clear + colors.inject(s[0]) do |memo, color|
            s[0].nil? ? __send__(color) + memo.to_s : __send__(color, memo.to_s)
          end
        end
      end
    end
  end
end