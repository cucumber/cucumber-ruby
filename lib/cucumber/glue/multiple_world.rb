# frozen_string_literal: true

module Cucumber
  module Glue
    # Raised if there are 2 or more World blocks.
    class MultipleWorld < StandardError
      def initialize(first_proc, second_proc)
        super(error_message(first_proc, second_proc))
      end

      def error_message(first_proc, second_proc)
        <<~MESSAGE
      You can only pass a proc to #World once, but it's happening
      in 2 places:
      #{Glue.backtrace_line(first_proc, 'World')}
      #{Glue.backtrace_line(second_proc, 'World')}
      Use Ruby modules instead to extend your worlds. See the Cucumber::Glue::Dsl#World RDoc
      or http://wiki.github.com/cucumber/cucumber/a-whole-new-world.


        MESSAGE
      end
    end

  end
end
