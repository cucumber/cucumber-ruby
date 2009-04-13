gem 'term-ansicolor'
require 'term/ansicolor'

if Cucumber::WINDOWS_MRI
  begin
    gem 'win32console', '>= 1.2.0'
    require 'Win32/Console/ANSI'
  rescue LoadError
    STDERR.puts %{*** WARNING: You must "gem install win32console" (1.2.0 or higher) to get coloured output on MRI/Windows}
    Term::ANSIColor.coloring = false
  end
elsif Cucumber::WINDOWS && Cucumber::JRUBY
  begin
    gem 'aslakhellesoy-ansicolor', '>= 1.0'
    require 'ansicolor'
  rescue LoadError
    STDERR.puts %{*** WARNING: You must "gem install aslakhellesoy-ansicolor --source http://gems.github.com" (1.0 or higher) to get coloured output on JRuby/Windows}
    Term::ANSIColor.coloring = false
  end
end

Term::ANSIColor.coloring = false if !STDOUT.tty? and not ENV.has_key?("AUTOTEST")

module Cucumber
  module Formatter
    # Defines aliases for coloured output. You can tweak the colours by defining
    # a <tt>CUCUMBER_COLORS</tt> variable in your shell, very much like you can
    # tweak the familiar POSIX command <tt>ls</tt> with
    # <a href="http://mipsisrisc.com/rambling/2008/06/27/lscolorsls_colors-now-with-linux-support/">$LSCOLORS/$LS_COLORS</a>
    #
    # The colours that you can change are:
    #
    # * <tt>undefined</tt>     - defaults to <tt>yellow</tt>
    # * <tt>pending</tt>       - defaults to <tt>yellow</tt>
    # * <tt>pending_param</tt> - defaults to <tt>yellow,bold</tt>
    # * <tt>failed</tt>        - defaults to <tt>red</tt>
    # * <tt>failed_param</tt>  - defaults to <tt>red,bold</tt>
    # * <tt>passed</tt>        - defaults to <tt>green</tt>
    # * <tt>passed_param</tt>  - defaults to <tt>green,bold</tt>
    # * <tt>outline</tt>       - defaults to <tt>cyan</tt>
    # * <tt>outline_param</tt> - defaults to <tt>cyan,bold</tt>
    # * <tt>skipped</tt>       - defaults to <tt>cyan</tt>
    # * <tt>skipped_param</tt> - defaults to <tt>cyan,bold</tt>
    # * <tt>comment</tt>       - defaults to <tt>grey</tt>
    # * <tt>tag</tt>           - defaults to <tt>cyan</tt>
    #
    # For instance, if your shell has a black background and a green font (like the
    # "Homebrew" settings for OS X' Terminal.app), you may want to override passed
    # steps to be white instead of green. Examples:
    #
    #   export CUCUMBER_COLORS="passed=white"
    #   export CUCUMBER_COLORS="passed=white,bold:passed_param=white,bold,underline"
    #
    # (If you're on Windows, use SET instead of export).
    # To see what colours and effects are available, just run this in your shell:
    #
    #   ruby -e "require 'rubygems'; require 'term/ansicolor'; puts Term::ANSIColor.attributes"
    #
    # Although not listed, you can also use <tt>grey</tt>
    module ANSIColor
      include Term::ANSIColor

      # Not supported in Term::ANSIColor
      def grey(m)
        if ::Term::ANSIColor.coloring?
          "\e[90m#{m}\e[0m"
        else
          m
        end
      end

      ALIASES = Hash.new do |h,k|
        if k.to_s =~ /(.*)_param/
          h[$1] + ',bold'
        end
      end.merge({
        'undefined' => 'yellow',
        'pending'   => 'yellow',
        'failed'    => 'red',
        'passed'    => 'green',
        'outline'   => 'cyan',
        'skipped'   => 'cyan',
        'comment'   => 'grey',
        'tag'       => 'cyan'
      })

      if ENV['CUCUMBER_COLORS'] # Example: export CUCUMBER_COLORS="passed=red:failed=yellow"
        ENV['CUCUMBER_COLORS'].split(':').each do |pair|
          a = pair.split('=')
          ALIASES[a[0]] = a[1]
        end
      end

      ALIASES.each do |method, color|
        unless method =~ /.*_param/
          code = <<-EOF
          def #{method}(string=nil, &proc)
            #{ALIASES[method].split(",").join("(") + "(string, &proc" + ")" * ALIASES[method].split(",").length}
          end
          # This resets the colour to the non-param colour
          def #{method}_param(string=nil, &proc)
            #{ALIASES[method+'_param'].split(",").join("(") + "(string, &proc" + ")" * ALIASES[method+'_param'].split(",").length} + #{ALIASES[method].split(",").join(' + ')}
          end
          EOF
          eval(code)
        end
      end
    end
  end
end
