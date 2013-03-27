module Cucumber
  module RbSupport
    module Snippet

      ARGUMENT_PATTERNS = ['"(.*?)"', '(\d+)']

      class BaseSnippet

        attr_reader :code_keyword, :pattern, :multiline_argument_class

        def initialize(code_keyword, pattern, multiline_argument_class)
          @code_keyword = code_keyword
          @pattern = pattern
          @multiline_argument_class = multiline_argument_class
        end

        def render
          replace_and_count_capturing_groups!
          render_snippet
        end

        private

        def replace_and_count_capturing_groups!
          @pattern = ::Regexp.escape(pattern).gsub('\ ', ' ').gsub('/', '\/')

          arg_count = 0

          ARGUMENT_PATTERNS.each do |pattern|
            @pattern = self.pattern.gsub(::Regexp.new(pattern), pattern)
            arg_count += self.pattern.scan(pattern).length
          end

          @number_of_arguments = arg_count
        end

        def render_snippet
          "#{code_keyword}#{typed_pattern} #{do_block}"
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
          block_args = (0...@number_of_arguments).map {|n| "arg#{n+1}"}

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

      end

      class Regexp < BaseSnippet
        def typed_pattern
          "(/^#{pattern}$/)"
        end
      end

      class Legacy < BaseSnippet
        def typed_pattern
          " /^#{pattern}$/"
        end
      end

      class Percent < BaseSnippet
        def typed_pattern
          " %r{^#{pattern}$}"
        end
      end

    end
  end
end
