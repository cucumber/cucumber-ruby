module Cucumber
  module Formatters
    class ProfileFormatter < ProgressFormatter
      NUMBER_OF_STEP_DEFINITONS_TO_SHOW = 10
      NUMBER_OF_STEP_INVOCATIONS_TO_SHOW = 5

      def initialize(io, step_mother)
        super(io)
        @step_mother = step_mother
        @step_times = Hash.new { |k,v| k[v] = [] }
        @step_keywords = {}
      end

      def visit_features(features)
        @io.puts "Profiling enabled.\n"
      end

      def step_executing(step, regexp, args)
        @step_time = Time.now
      end

      def step_passed(step, regexp, args)
        execution_time = Time.now - @step_time
        super
        @step_keywords[regexp] ||= step.actual_keyword unless step.row?
        invocation_comment = ''
        definition_comment = ''

        if step.row?
          description = ''
          args.each do |arg|
            description +=  %{|#{arg}|}
          end
        else
          description = "#{step.keyword} #{step.format(regexp){|param| underline(param)}}"
          definition_comment = source(step)
        end
        invocation_comment = "# #{step.file}:#{step.line}"
        @step_times["#{@step_keywords[regexp]} #{regexp.inspect}"] << [description, invocation_comment, definition_comment, execution_time]
      end

      def dump
        super
        @io.puts "\n\nTop #{NUMBER_OF_STEP_DEFINITONS_TO_SHOW} average slowest steps with #{NUMBER_OF_STEP_INVOCATIONS_TO_SHOW} slowest matches:\n"

        mean_times = map_to_mean_times(@step_times)
        mean_times = mean_times.sort_by { |step_profiles, keyword_regexp, mean_execution_time| mean_execution_time }.reverse

        mean_times[0...NUMBER_OF_STEP_DEFINITONS_TO_SHOW].each do |step_profiles, keyword_regexp, mean_execution_time|
          print_step_definition(step_profiles, keyword_regexp, mean_execution_time)
          step_profiles = step_profiles.sort_by { |description, invocation_comment, definition_comment, execution_time| execution_time }.reverse
          print_step_invocations(step_profiles, keyword_regexp)
        end
      end

      private
      def map_to_mean_times(step_times)
        mean_times = []
        step_times.each do |regexp, step_profiles|
          mean_execution_time = (step_profiles.inject(0) { |sum, step_details| step_details[3] + sum } / step_profiles.length)
          mean_times << [step_profiles, regexp, mean_execution_time]
        end
        mean_times
      end

      def print_step_definition(step_profiles, keyword_regexp, mean_execution_time)
        unless step_profiles.empty?
          _, _, definition_comment, _ = step_profiles.first
          @io.print red(sprintf("%.7f",  mean_execution_time))
          @io.print "  #{keyword_regexp}"
          @io.print "  #{comment(definition_comment)}"
          @io.puts
        end
      end

      def print_step_invocations(step_profiles, keyword_regexp)
        step_profiles[0...NUMBER_OF_STEP_INVOCATIONS_TO_SHOW].each do |description, invocation_comment, definition_comment, execution_time|
          @io.print "  #{yellow(sprintf("%.7f", execution_time))}"
          @io.print "  #{description}"
          @io.print "  #{comment(invocation_comment)}"
          @io.puts
        end
      end

      def source(step)
        _, _, proc = step.regexp_args_proc(@step_mother)
        proc.to_comment_line
      end

    end
  end
end
