# frozen_string_literal: true

module Cucumber
  module Term
    # The ANSIColor module can be used for namespacing and mixed into your own
    # classes.
    module ANSIColor
      module_function

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
      COLORED_REGEXP = /\e\[(?:[34][0-7]|[0-9])?m/

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

      # rubocop:disable Security/Eval
      ATTRIBUTES.each do |c, v|
        eval <<-END_EVAL, binding, __FILE__, __LINE__ + 1
            def #{c}(string = nil)
              result = String.new
              result << "\e[#{v}m" if Cucumber::Term::ANSIColor.coloring?
              if block_given?
                result << yield
              elsif string
                result << string
              elsif respond_to?(:to_str)
                result << to_str
              else
                return result #only switch on
              end
              result << "\e[0m" if Cucumber::Term::ANSIColor.coloring?
              result
            end
        END_EVAL
      end
      # rubocop:enable Security/Eval

      # Returns an uncolored version of the string, that is all
      # ANSI-sequences are stripped from the string.
      def uncolored(string = nil)
        if block_given?
          uncolorize(yield)
        elsif string
          uncolorize(string)
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

      def uncolorize(string)
        string.gsub(COLORED_REGEXP, '')
      end
    end
  end
end
