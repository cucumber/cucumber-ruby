require 'forwardable'
require 'cucumber/core/ast/doc_string'
require 'cucumber/core/ast/data_table'

module Cucumber
  class Runtime
    # This is what a programming language will consider to be a runtime.
    #
    # It's a thin class that directs the handul of methods needed by the
    # programming languages to the right place.
    class ForProgrammingLanguages
      extend Forwardable

      def initialize(support_code, user_interface)
        @support_code, @user_interface = support_code, user_interface
      end

      def_delegators :@user_interface,
        :embed,
        :ask,
        :puts,
        :features_paths,
        :step_match

      def_delegators :@support_code,
        :invoke_steps,
        :invoke,
        :load_programming_language

      # Returns a Cucumber::Core::Ast::DataTable for +text_or_table+, which can either
      # be a String:
      #
      #   table(%{
      #     | account | description | amount |
      #     | INT-100 | Taxi        | 114    |
      #     | CUC-101 | Peeler      | 22     |
      #   })
      #
      # or a 2D Array:
      #
      #   table([
      #     %w{ account description amount },
      #     %w{ INT-100 Taxi        114    },
      #     %w{ CUC-101 Peeler      22     }
      #   ])
      #
      def table(text_or_table, file=nil, line_offset=0)
        file, line = *caller[0].split(':')[0..1]
        location = Core::Ast::Location.new(file, line)
        if Array === text_or_table
          Core::Ast::DataTable.new(text_or_table, location)
        else
          Core::Ast::DataTable.parse(text_or_table, file, location)
        end
      end

      # Returns Ast::DocString for +string_without_triple_quotes+.
      #
      def doc_string(string_without_triple_quotes, content_type='', line_offset=0)
        file, line = *caller[0].split(':')[0..1]
        location = Core::Ast::Location.new(file, line)
        Core::Ast::DocString.new(string_without_triple_quotes,content_type, location)
      end
    end
  end
end
