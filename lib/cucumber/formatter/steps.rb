module Cucumber
  module Formatter
    class Steps < Ast::Visitor

      def initialize(step_mother, io, options)
        super(step_mother)
        @io = io
        @options = options
        @steps = step_mother.step_definitions.inject({}) do |steps, step|
          regexp = step.regexp
          source = source_file(step)
          steps[source] ||= []
          steps[source] << regexp.to_s[8..-3]
          steps
        end
      end

      def visit_features(features)
        count = 0
        @steps.keys.sort.each do |source|
          @io.puts "Source: #{source}"
          @steps[source].sort.each do |step|
            @io.puts step.indent(2)
          end
          @io.puts
          count += @steps[source].size
        end
        @io.puts "#{count} step(s) defined in #{@steps.keys.size} source file(s)."
      end

      # a little trick to catch the source file of a step definition
      # by raising a dummy exception using the step's proc binding
      def source_file(step)
        binding = step.proc.binding
        begin
          eval "raise 'Dummy Exception'", binding
        rescue => ex
          return File.basename(ex.backtrace[0]) # we caught the source!
        end
      end

    end
  end
end