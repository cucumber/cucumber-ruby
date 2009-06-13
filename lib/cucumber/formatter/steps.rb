module Cucumber
  module Formatter
    class Steps < Ast::Visitor

      def initialize(step_mother, io, options)
        super(step_mother)
        @io = io
        @options = options
        @steps = collect_steps(step_mother)
      end

      def visit_features(features)
        print_summary
      end

      private

      def print_summary
        count = 0
        @steps.keys.sort.each do |source|
          @io.puts "#{source}"
          source_indent = source_indent(@steps[source])
          @steps[source].sort.each do |file_name, line_number, step|
            @io.print "#{step}".indent(2)
            @io.print " # #{file_name}#{line_number}".indent(source_indent - step.size)
            @io.puts
          end
          @io.puts
          count += @steps[source].size
        end
        @io.puts "#{count} step(s) defined in #{@steps.keys.size} source file(s)."
      end

      def collect_steps(step_mother)
        step_mother.step_definitions.inject({}) do |steps, step|
          regexp = step.regexp
          file_name, line_number = source_file(step)
          steps[file_name] ||= []
          steps[file_name] << [ file_name, line_number, regexp.to_s[8..-3] ]
          steps
        end
      end

      # a little trick to catch the source file of a step definition
      # by raising a dummy exception using the step's proc binding
      def source_file(step)
        binding = step.proc.binding
        begin
          eval "raise 'Dummy Exception'", binding
        rescue => ex
          return parse_backtrace(ex.backtrace[0]) # we caught the source!
        end
      end

      def parse_backtrace(backtrace)
        backtrace =~ /.*\/(.+)(:.*)/
        [ $1, $2 ]
      end

      def source_indent(steps)
        steps.map { |file_name, line_number, step| step.size }.max + 1
      end
    end
  end
end