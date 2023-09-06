# frozen_string_literal: true

module Cucumber
  module Term
    # This module allows to colorize text using ANSI escape sequences.
    #
    # Include the module in your class and use its methods to colorize text.
    #
    # Example:
    #
    #   require 'cucumber/term/ansicolor'
    #
    #   class MyFormatter
    #     include Cucumber::Term::ANSIColor
    #
    #     def initialize(config)
    #       $stdout.puts yellow("Initializing formatter")
    #       $stdout.puts green("Coloring is active \o/") if Cucumber::Term::ANSIColor.coloring?
    #       $stdout.puts grey("Feature path:") + blue(bold(config.feature_dirs))
    #     end
    #   end
    #
    # To see what colours and effects are available, just run this in your shell:
    #
    #   ruby -e "require 'rubygems'; require 'cucumber/term/ansicolor'; puts Cucumber::Term::ANSIColor.attributes"
    #
    module ANSIColor
      # :stopdoc:
      ATTRIBUTES = [
        [:clear,         0],
        [:reset,         0], # synonym for :clear
        [:bold,          1],
        [:dark,          2],
        [:italic,        3], # not widely implemented
        [:underline,     4],
        [:underscore,    4], # synonym for :underline
        [:blink,         5],
        [:rapid_blink,   6], # not widely implemented
        [:negative,      7], # no reverse because of String#reverse
        [:concealed,     8],
        [:strikethrough, 9], # not widely implemented
        [:black,         30],
        [:red,           31],
        [:green,         32],
        [:yellow,        33],
        [:blue,          34],
        [:magenta,       35],
        [:cyan,          36],
        [:white,         37],
        [:grey,          90],
        [:on_black,      40],
        [:on_red,        41],
        [:on_green,      42],
        [:on_yellow,     43],
        [:on_blue,       44],
        [:on_magenta,    45],
        [:on_cyan,       46],
        [:on_white,      47]
      ].freeze

      ATTRIBUTE_NAMES = ATTRIBUTES.transpose.first
      # :startdoc:

      # Regular expression that is used to scan for ANSI-sequences while
      # uncoloring strings.
      COLORED_REGEXP = /\e\[(?:[34][0-7]|[0-9])?m/.freeze

      @coloring = true

      class << self
        # Turns the coloring on or off globally, so you can easily do
        # this for example:
        #  Cucumber::Term::ANSIColor::coloring = $stdout.isatty
        attr_accessor :coloring

        # Returns true, if the coloring function of this module
        # is switched on, false otherwise.
        alias coloring? :coloring

        def included(klass)
          return unless klass == String

          ATTRIBUTES.delete(:clear)
          ATTRIBUTE_NAMES.delete(:clear)
        end
      end

      ATTRIBUTES.each do |color_name, color_code|
        define_method(color_name) do |text = nil, &block|
          if block
            colorize(block.call, color_code)
          elsif text
            colorize(text, color_code)
          elsif respond_to?(:to_str)
            colorize(to_str, color_code)
          else
            colorize(nil, color_code) # switch coloration on
          end
        end
      end

      # Returns an uncolored version of the string
      # ANSI-sequences are stripped from the string.
      def uncolored(text = nil)
        if block_given?
          uncolorize(yield)
        elsif text
          uncolorize(text)
        elsif respond_to?(:to_str)
          uncolorize(to_str)
        else
          ''
        end
      end

      # Returns an array of all Cucumber::Term::ANSIColor attributes as symbols.
      def attributes
        ATTRIBUTE_NAMES
      end

      private

      def colorize(text, color_code)
        return String.new(text || '') unless Cucumber::Term::ANSIColor.coloring?
        return "\e[#{color_code}m" unless text

        "\e[#{color_code}m#{text}\e[0m"
      end

      def uncolorize(string)
        string.gsub(COLORED_REGEXP, '')
      end
    end
  end
end
