# frozen_string_literal: true

require 'cucumber/platform'
require 'cucumber/term/ansicolor'

Cucumber::Term::ANSIColor.coloring = false unless $stdout.tty?

module Cucumber
  module Formatter
    # This module allows to format cucumber related outputs using ANSI escape sequences.
    #
    # For example, it provides a `passed` method which returns the string with
    # the ANSI escape sequence to format it green per default.
    #
    # To use this, include or extend it in your class.
    #
    # Example:
    #
    #   require 'cucumber/formatter/ansicolor'
    #
    #   class MyFormatter
    #     extend Cucumber::Term::ANSIColor
    #
    #     def on_test_step_finished(event)
    #       $stdout.puts undefined(event.test_step) if event.result.undefined?
    #       $stdout.puts passed(event.test_step) if event.result.passed?
    #     end
    #   end
    #
    # This module also allows the user to customize the format of cucumber outputs
    # using environment variables.
    #
    # For instance, if your shell has a black background and a green font (like the
    # "Homebrew" settings for OS X' Terminal.app), you may want to override passed
    # steps to be white instead of green.
    #
    # Example:
    #
    #   export CUCUMBER_COLORS="passed=white,bold:passed_param=white,bold,underline"
    #
    # The colours that you can change are:
    #
    # * <tt>undefined</tt>     - defaults to <tt>yellow</tt>
    # * <tt>pending</tt>       - defaults to <tt>yellow</tt>
    # * <tt>pending_param</tt> - defaults to <tt>yellow,bold</tt>
    # * <tt>flaky</tt>         - defaults to <tt>yellow</tt>
    # * <tt>flaky_param</tt>   - defaults to <tt>yellow,bold</tt>
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
    # To see what colours and effects are available, just run this in your shell:
    #
    #   ruby -e "require 'rubygems'; require 'cucumber/term/ansicolor'; puts Cucumber::Term::ANSIColor.attributes"
    #
    module ANSIColor
      include Cucumber::Term::ANSIColor

      ALIASES = Hash.new do |h, k|
        next unless k.to_s =~ /(.*)_param/

        "#{h[Regexp.last_match(1)]},bold"
      end.merge(
        'undefined' => 'yellow',
        'pending' => 'yellow',
        'flaky' => 'yellow',
        'failed' => 'red',
        'passed' => 'green',
        'outline' => 'cyan',
        'skipped' => 'cyan',
        'comment' => 'grey',
        'tag' => 'cyan'
      )

      # Apply the custom color scheme -> i.e. apply_custom_colors('passed=white')
      def self.apply_custom_colors(colors)
        colors.split(':').each do |pair|
          a = pair.split('=')
          ALIASES[a[0]] = a[1]
        end
      end
      apply_custom_colors(ENV['CUCUMBER_COLORS']) if ENV['CUCUMBER_COLORS']

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
        next if method_name.end_with?('_param')

        define_method(method_name) do |text = nil, &proc|
          apply_styles(ALIASES[method_name], text, &proc)
        end

        define_method("#{method_name}_param") do |text = nil, &proc|
          apply_styles(ALIASES["#{method_name}_param"], text, &proc) + apply_styles(ALIASES[method_name])
        end
      end

      def cukes(amount)
        ('(::) ' * amount).strip
      end

      def green_cukes(amount)
        blink(green(cukes(amount)))
      end

      def red_cukes(amount)
        blink(red(cukes(amount)))
      end

      def yellow_cukes(amount)
        blink(yellow(cukes(amount)))
      end

      private

      def apply_styles(styles, text = nil, &proc)
        styles.split(',').reverse.reduce(text) do |result, method_name|
          send(method_name, result, &proc)
        end
      end
    end
  end
end
