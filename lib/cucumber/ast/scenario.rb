module Cucumber
  module Ast
    class Scenario
      attr_reader :comment, :tags, :name, :steps
      
      def initialize(comment, tags, name, steps)
        @comment, @tags, @name, @steps = comment, tags, name, steps
      end

      def format(io)
        comment.format(io, 2)
        tags.format(io, 2)
        io.write("  Scenario: #{@name}\n")
        steps.each {|step| step.format(io)}
      end
    end
  end
end