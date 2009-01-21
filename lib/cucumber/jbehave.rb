require 'java'

$:.unshift(ENV['HOME'] + '/.m2/repository/org/hamcrest/hamcrest-all/1.1')
$:.unshift(ENV['HOME'] + '/.m2/repository/junit/junit/4.4')
$:.unshift(ENV['HOME'] + '/.m2/repository/org/jbehave/jbehave-core/2.1')

require 'hamcrest-all-1.1.jar'
require 'junit-4.4.jar'
require 'jbehave-core-2.1.jar'

module Cucumber
  module JBehave
    # Register an instance of org.jbehave.scenario.steps.Steps
    def JBehave(jbehave_steps)
      jbehave_steps.getSteps.each do |jbehave_candidate_step|
        step_definitions << JBehaveStepDefinition.new(jbehave_steps, jbehave_candidate_step)
      end
    end
    
    # Open up so we can get the pattern....
    JBehaveCandidateStep = org.jbehave.scenario.steps.CandidateStep
    class JBehaveCandidateStep
      field_reader :pattern
    end
    
    # Adapter for JBehave org.jbehave.scenario.steps.CandidateStep
    class JBehaveStepDefinition
      def initialize(jbehave_steps, jbehave_candidate_step)
        @jbehave_steps = jbehave_steps
        @jbehave_candidate_step = jbehave_candidate_step
      end
      
      def match(step_name)
        full_text = "Given #{step_name}" # JBehave doesn't distinguish GWT internally :-)
        @jbehave_candidate_step.matches(full_text)
      end
      
      def file_colon_line
        @jbehave_steps.java_class.name
      end

      def format_args(step_name, format)
        java_pattern = @jbehave_candidate_step.pattern.pattern
        regexp = Regexp.new(java_pattern)
        step_name.gzub(regexp, format)
      end

      def matched_args(step_name)
        java_pattern = @jbehave_candidate_step.pattern.pattern
        regexp = Regexp.new(java_pattern)
        step_name.match(regexp).captures
      end

      def execute(step_name, world, *args)
        step = @jbehave_candidate_step.createFrom("Given #{step_name}")
        result = step.perform
        result.describeTo(JBehave::REPORTER)
      end
    end

    class JBehaveException < Exception
    end

    # Implements the org.jbehave.scenario.reporters.ScenarioReporter methods
    class Reporter
      def successful(step_text)
        # noop
      end

      def failed(step, java_exception)
        raise java_exception_to_ruby_exception(java_exception)
      end

      private
      
      def java_exception_to_ruby_exception(java_exception)
        # OK, this is a little funky - JRuby weirdness
        ruby_exception = org.jruby.NativeException.new(JRuby.runtime, JBehaveException, java_exception)
        ruby_exception.set_backtrace([]) # work around backtrace bug in jruby
        
        exception = JBehaveException.new(java_exception.getMessage)
        exception.set_backtrace(ruby_exception.backtrace.reject{|line| line =~ /^org\/jruby/})
        exception
      end
    end
    
    REPORTER = Reporter.new
  end
end

self.extend(Cucumber::JBehave)