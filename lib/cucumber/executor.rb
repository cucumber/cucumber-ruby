module Cucumber
  class Executor
    attr_reader :failed
    attr_accessor :formatters
    attr_writer :scenario_names, :lines_for_features

    def initialize(step_mother)
      @world_procs = []
      @before_scenario_procs = []
      @after_scenario_procs = []
      @after_step_procs = []
      @step_mother = step_mother

      @executed_scenarios = {}
      @regular_scenario_cache = {}
    end

    def register_world_proc(&proc)
      @world_procs << proc
    end

    def register_before_scenario_proc(&proc)
      proc.extend(CoreExt::CallIn)
      @before_scenario_procs << proc
    end

    def register_after_scenario_proc(&proc)
      proc.extend(CoreExt::CallIn)
      @after_scenario_procs << proc
    end

    def register_after_step_proc(&proc)
      proc.extend(CoreExt::CallIn)
      @after_step_procs << proc
    end

    def visit_features(features)
      formatters.visit_features(features)
      features.accept(self)
      formatters.dump
    end

    def visit_feature(feature)
      @feature_file = feature.file
            
      if accept_feature?(feature)
        formatters.feature_executing(feature)
        feature.accept(self)
        @executed_scenarios = {}
        @regular_scenario_cache = {}
      end
    end

    def visit_header(header)
      formatters.header_executing(header)
    end

    def visit_row_scenario(scenario)
      execute_scenario(@regular_scenario_cache[scenario.name]) if executing_unprepared_row_scenario?(scenario)
      visit_scenario(scenario)
    end

    def visit_regular_scenario(scenario)
      @regular_scenario_cache[scenario.name] = scenario
      visit_scenario(scenario)
    end

    def visit_scenario_outline(scenario)
      visit_regular_scenario(scenario)
    end

    def visit_scenario(scenario)
      if accept_scenario?(scenario)
        @executed_scenarios[scenario.name] = true
        execute_scenario(scenario)
      end
    end

    def execute_scenario(scenario)
      @error = nil
      @pending = nil

      @world = create_world

      formatters.scenario_executing(scenario)
      @before_scenario_procs.each{|p| p.call_in(@world, *[])}
      scenario.accept(self)
      @after_scenario_procs.each{|p| p.call_in(@world, *[])}
      formatters.scenario_executed(scenario)
    end
    
    def accept_scenario?(scenario)
      scenario_at_specified_line?(scenario) &&
      scenario_has_specified_name?(scenario)
    end

    def accept_feature?(feature)
      feature.scenarios.any? { |s| accept_scenario?(s) }
    end

    def visit_row_step(step)
      visit_step(step)
    end

    def visit_regular_step(step)
      visit_step(step)
    end

    def visit_step_outline(step)
      regexp, args, proc = step.regexp_args_proc(@step_mother)
      formatters.step_traced(step, regexp, args)
    end

    def visit_step(step)
      unless @pending || @error
        begin
          regexp, args, proc = step.regexp_args_proc(@step_mother)
          formatters.step_executing(step, regexp, args)
          step.execute_in(@world, regexp, args, proc)
          @after_step_procs.each{|p| p.call_in(@world, *[])}
          formatters.step_passed(step, regexp, args)
        rescue ForcedPending => e
          step.error = e
          record_pending_step(step, regexp, args)
        rescue Pending
          record_pending_step(step, regexp, args)
        rescue => e
          @failed = true
          @error = step.error = e
          formatters.step_failed(step, regexp, args)
        end
      else
        begin
          regexp, args, proc = step.regexp_args_proc(@step_mother)
          step.execute_in(@world, regexp, args, proc)
          formatters.step_skipped(step, regexp, args)
        rescue ForcedPending => e
          step.error = e
          record_pending_step(step, regexp, args)
        rescue Pending
          record_pending_step(step, regexp, args)
        rescue Exception
          formatters.step_skipped(step, regexp, args)
        end
      end
    end

    def record_pending_step(step, regexp, args)
      @pending = true
      formatters.step_pending(step, regexp, args)
    end

    def executing_unprepared_row_scenario?(scenario)
      accept_scenario?(scenario) && !@executed_scenarios[scenario.name]
    end
    
    def scenario_at_specified_line?(scenario)
      if lines_defined_for_current_feature?
        @lines_for_features[@feature_file].inject(false) { |at_line, line| at_line || scenario.at_line?(line) }
      else
        true
      end
    end
    
    def scenario_has_specified_name?(scenario)
      if @scenario_names && !@scenario_names.empty?
        @scenario_names.include?(scenario.name)
      else
        true
      end
    end
    
    def lines_defined_for_current_feature?
      @lines_for_features && !@lines_for_features[@feature_file].nil? && !@lines_for_features[@feature_file].empty?
    end
    
    def create_world
      world = Object.new
      @world_procs.each do |world_proc|
        world = world_proc.call(world)
      end

      world.extend(World::Pending)
      world.extend(::Spec::Matchers) if defined?(::Spec::Matchers)
      define_step_call_methods(world)
      world
    end

    def define_step_call_methods(world)
      world.instance_variable_set('@__executor', self)
      world.instance_eval do
        class << self
          def run_step(name)
            _, args, proc = @__executor.instance_variable_get(:@step_mother).regexp_args_proc(name)
            proc.call_in(self, *args)
          end

          %w{given when then and but}.each do |keyword|
            alias_method Cucumber.language[keyword], :run_step
          end
        end
      end
    end
  end
end
