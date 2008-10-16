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

      def scenario_executing(scenario)
        @scenario_time = Time.now
      end

      def step_passed(step, regexp, args)
        execution_time = Time.now - @step_time
        super
        @step_keywords[regexp] ||= step.actual_keyword unless step.row?
        @step_times["#{@step_keywords[regexp]} #{regexp.inspect}"] << [step, execution_time]
      end

      def dump
        super
        @io.puts "\n\nTop 10 average slowest steps with 5 slowest matches:\n"

        mean_times = map_to_mean_times(@step_times)
        mean_times = mean_times.sort_by { |step_profile_list, keyword_regexp, mean_time| mean_time }.reverse

        mean_times[0...NUMBER_OF_STEP_DEFINITONS_TO_SHOW].each do |step_profile, keyword_regexp, mean_time|
          print_step_definition(step_profile, keyword_regexp, mean_time)
          step_profile = step_profile.sort_by { |step, time| time }.reverse
          print_step_invocations(step_profile, keyword_regexp)
        end
      end

      private
      def map_to_mean_times(step_times)
        mean_times = []
        step_times.each do |regexp, step_profile_list|
          mean_time = (step_profile_list.inject(0) { |sum, step_details| step_details[1] + sum } / step_profile_list.length)
          mean_times << [step_profile_list, regexp, mean_time]
        end
        mean_times
      end

      def print_step_definition(step_profile, keyword_regexp, mean_time)
        unless step_profile.empty?
          first_step = step_profile.first[0]
          
          @io.print red(sprintf("%.7f",  mean_time))
          @io.print "  #{keyword_regexp}"
          @io.print "  #{source_comment(first_step)}"
          @io.puts
        end
      end

      def print_step_invocations(step_profile, keyword_regexp)
        step_profile[0...NUMBER_OF_STEP_INVOCATIONS_TO_SHOW].each do |step, time|
          regexp, args, _ = step.regexp_args_proc(@step_mother)
          
          @io.print "   " + yellow(sprintf("%.7f", time))

          if step.row?
            @io.print "  "
            args.each do |arg|
              @io.print %{|#{arg}|}
            end
          else
            @io.print "  #{step.keyword} #{step.format(regexp){|param| underline(param)}}"
          end

          @io.print comment("  # #{step.file}:#{step.line} ")
          @io.puts
        end
      end
         
      def source_comment(step)
        _, _, proc = step.regexp_args_proc(@step_mother)
        comment(proc.to_comment_line)
      end

    end
  end
end
