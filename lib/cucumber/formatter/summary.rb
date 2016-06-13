module Cucumber
  module Formatter
    module Summary

      def scenario_summary(runtime, &block)
        scenarios_proc = lambda{|status| elements = runtime.scenarios(status)}
        scenario_count_proc = element_count_proc(scenarios_proc)
        dump_summary_counts(runtime.scenarios.length, scenario_count_proc, "scenario", &block)
      end

      def step_summary(runtime, &block)
        steps_proc = lambda{|status| runtime.steps(status)}
        step_count_proc = element_count_proc(steps_proc)
        dump_summary_counts(runtime.steps.length, step_count_proc, "step", &block)
      end

      def dump_summary_counts(total_count, status_proc, what, &block)
        dump_count(total_count, what) + dump_status_counts(status_proc, &block)
      end

      private

      def element_count_proc(find_elements_proc)
        lambda { |status|
          elements = find_elements_proc.call(status)
          elements.any? ? elements.length : 0
        }
      end

      def dump_status_counts(element_count_proc)
        counts = [:failed, :skipped, :undefined, :pending, :passed].map do |status|
          count = element_count_proc.call(status)
          count != 0 ? yield("#{count} #{status.to_s}", status) : nil
        end.compact
        if counts.any?
          " (#{counts.join(', ')})"
        else
          ""
        end
      end

      def dump_count(count, what, state=nil)
        [count, state, "#{what}#{count == 1 ? '' : 's'}"].compact.join(" ")
      end

    end
  end
end
