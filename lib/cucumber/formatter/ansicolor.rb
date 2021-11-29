# frozen_string_literal: true

require 'cucumber/platform'
require 'cucumber/term/ansicolor'

Cucumber::Term::ANSIColor.coloring = false if !$stdout.tty? && !ENV.key?('AUTOTEST')

module Cucumber
  module Formatter
    # Defines aliases for coloured output. You don't invoke any methods from this
    # module directly, but you can change the output colours by defining
    # a <tt>CUCUMBER_COLORS</tt> variable in your shell, very much like how you can
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
    # steps to be white instead of green.
    #
    # Although not listed, you can also use <tt>grey</tt>.
    #
    # Examples: (On Windows, use SET instead of export.)
    #
    #   export CUCUMBER_COLORS="passed=white"
    #   export CUCUMBER_COLORS="passed=white,bold:passed_param=white,bold,underline"
    #
    # To see what colours and effects are available, just run this in your shell:
    #
    #   ruby -e "require 'rubygems'; require 'term/ansicolor'; puts Cucumber::Term::ANSIColor.attributes"
    #
    module ANSIColor
      include Cucumber::Term::ANSIColor

      ALIASES = Hash.new do |h, k|
        next unless k.to_s =~ /(.*)_param/

        "#{h[Regexp.last_match(1)]},bold"
      end.merge(
        'undefined' => 'yellow',
        'pending'   => 'yellow',
        'flaky'     => 'yellow',
        'failed'    => 'red',
        'passed'    => 'green',
        'outline'   => 'cyan',
        'skipped'   => 'cyan',
        'comment'   => 'grey',
        'tag'       => 'cyan'
      )

      def customize_colors(colors)
        colors.split(':').each do |pair|
          a = pair.split('=')
          ALIASES[a[0]] = a[1]
        end
      end

      customize_colors(ENV['CUCUMBER_COLORS']) if ENV['CUCUMBER_COLORS'] # Example: export CUCUMBER_COLORS="passed=red:failed=yellow"

      # Define the color-named methods required by Term::ANSIColor.
      #
      # Examples:
      #
      #   def failed(string=nil, &proc)
      #     red(string, &proc)
      #   end
      #
      #   def failed_param(string=nil, &proc)
      #     red(bold(string, &proc)) + red
      #   end
      ALIASES.each_key do |method_name|
        next if method_name =~ /.*_param/

        define_method(method_name) do |string = nil, &proc|
          apply_styles(ALIASES[method_name], string, &proc)
        end

        define_method("#{method_name}_param") do |string = nil, &proc|
          apply_styles(ALIASES["#{method_name}_param"], string, &proc) + apply_styles(ALIASES[method_name])
        end
      end

      def apply_styles(styles, string = nil, &proc)
        styles.split(',').reverse.reduce(string) do |result, method_name|
          send(method_name, result, &proc)
        end
      end

      def cukes(n)
        ('(::) ' * n).strip
      end

      def green_cukes(n)
        blink(green(cukes(n)))
      end

      def red_cukes(n)
        blink(red(cukes(n)))
      end

      def yellow_cukes(n)
        blink(yellow(cukes(n)))
      end
    end
  end
end
