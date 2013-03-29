module Cucumber
  module RbSupport
    module Snippet

      ARGUMENT_PATTERNS = ['"(.*?)"', '(\d+)']

      class BaseSnippet

        def initialize(code_keyword, pattern, multiline_argument_class)
          @number_of_arguments = 0
          @code_keyword = code_keyword
          @pattern = replace_and_count_capturing_groups(pattern)
          @multiline_argument_class = multiline_argument_class
        end

        def to_s
          "#{step} #{do_block}"
        end

        def step
          "#{code_keyword}#{typed_pattern}"
        end

        def self.cli_option_string(type)
          "%-7s: %-28s e.g. %s" % [type, description, example]
        end

        private

        attr_reader :code_keyword, :pattern, :multiline_argument_class, :number_of_arguments

        def replace_and_count_capturing_groups(pattern)
          modified_pattern = ::Regexp.escape(pattern).gsub('\ ', ' ').gsub('/', '\/')

          ARGUMENT_PATTERNS.each do |argument_pattern|
            modified_pattern.gsub!(::Regexp.new(argument_pattern), argument_pattern)
            @number_of_arguments += modified_pattern.scan(argument_pattern).length
          end

          modified_pattern
        end

        def do_block
          do_block = ""
          do_block << "do#{arguments}\n"
          do_block << multiline_comment if multiline_argument_class?
          do_block << "  pending # express the regexp above with the code you wish you had\n"
          do_block << "end"
          do_block
        end

        def arguments
          block_args = (0...number_of_arguments).map { |n| "arg#{n+1}" }

          if multiline_argument_class
            block_args << multiline_argument_class.default_arg_name
          end

          block_args.empty? ? "" : " |#{block_args.join(", ")}|"
        end

        def multiline_comment
          "  # #{multiline_argument_class.default_arg_name} is a #{multiline_argument_class.to_s}\n"
        end

        def multiline_argument_class?
          multiline_argument_class == Ast::Table
        end

        def self.example
          new("Given", "missing step", nil).step
        end

      end

      class Regexp < BaseSnippet
        def typed_pattern
          "(/^#{pattern}$/)"
        end

        def self.description
          "Snippets with parentheses"
        end
      end

      class Classic < BaseSnippet
        def typed_pattern
          " /^#{pattern}$/"
        end

        def self.description
          "Snippets without parentheses. Note that these cause a warning from modern versions of Ruby."
        end
      end

      class Percent < BaseSnippet
        def typed_pattern
          " %r{^#{pattern}$}"
        end

        def self.description
          "Snippets with percent regexp"
        end
      end

    end
  end
end
