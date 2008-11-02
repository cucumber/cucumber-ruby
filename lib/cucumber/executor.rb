require 'cucumber/core_ext/proc'

module Cucumber
  class Executor
    attr_reader :failed
    attr_accessor :formatters
    attr_writer :scenario_names

    def line=(line)
      @line = line
    end

    def initialize(step_mother)
      @world_proc = lambda do
        Object.new
      end
      @before_scenario_procs = []
      @after_scenario_procs = []
      @after_step_procs = []
      @step_mother = step_mother

      @executed_scenarios = {}
      @regular_scenario_cache = {}
    end

    def register_world_proc(&proc)
      @world_proc = proc
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
      raise "Line number can only be specified when there is 1 feature. There were #{features.length}." if @line && features.length != 1
      formatters.visit_features(features)
      features.accept(self)
      formatters.dump
    end

    def visit_feature(feature)
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

    def visit_scenario(scenario)
      if accept_scenario?(scenario)
        @executed_scenarios[scenario.name] = true
        execute_scenario(scenario)
      end
    end

    def execute_scenario(scenario)
      @error = nil
      @pending = nil

      @world = @world_proc.call
      @world.extend(Spec::Matchers) if defined?(Spec::Matchers)
      define_step_call_methods(@world)

      formatters.scenario_executing(scenario)
      @before_scenario_procs.each{|p| p.call_in(@world, *[])}
      scenario.accept(self)
      @after_scenario_procs.each{|p| p.call_in(@world, *[])}
      formatters.scenario_executed(scenario)
    end
    
    def accept_scenario?(scenario)
      accept = true
      accept &&= scenario.at_line?(@line) if @line
      accept &&= @scenario_names.include? scenario.name if @scenario_names && !@scenario_names.empty?
      accept
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

    def visit_step(step)
      unless @pending || @error
        begin
          regexp, args, proc = step.regexp_args_proc(@step_mother)
          formatters.step_executing(step, regexp, args)
          step.execute_in(@world, regexp, args, proc)
          @after_step_procs.each{|p| p.call_in(@world, *[])}
          formatters.step_passed(step, regexp, args)
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
    
    def executing_unprepared_row_scenario?(scenario)
      accept_scenario?(scenario) && !@executed_scenarios[scenario.name]
    end
    
  end
end
