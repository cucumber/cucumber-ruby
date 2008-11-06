require 'autotest'

module Autotest::CucumberMixin
  def self.included(receiver)
    receiver::ALL_HOOKS << [:run_features, :ran_features]
  end
  
  attr_accessor :scenarios_to_run, :feature_results
  
  def initialize
    super
    reset_features
  end
  
  def run
    hook :initialize
    reset
    reset_features
    add_sigint_handler

    self.last_mtime = Time.now if $f

    loop do # ^c handler
      begin
        get_to_green
        if self.tainted then
          rerun_all_tests
          rerun_all_features if all_good
        else
          hook :all_good
        end
        wait_for_changes
        # Once tests and features are green, reset features every
        # time a file is changed to see if anything breaks.
        reset_features
      rescue Interrupt
        break if self.wants_to_quit
        reset
        reset_features
      end
    end
    hook :quit
  end
  
  def all_features_good
    scenarios_to_run == []
  end
  
  def get_to_green
    begin
      super
      run_features
      wait_for_changes unless all_features_good
    end until all_features_good
  end
  
  def rerun_all_features
    reset_features
    run_features
  end
  
  def reset_features
    self.scenarios_to_run = :all
  end
    
  # This resuses a lot of Autotest's logic, but there's
  # no way to hijack it for Cucumber without interfering
  # with tests/specs.
  def run_features
    hook :run_features
    cmd = self.make_cucumber_cmd self.scenarios_to_run
    return if cmd.empty?
    
    puts cmd unless $q
    
    old_sync = $stdout.sync
    $stdout.sync = true
    self.feature_results = []
    line = []
    begin
      open("| #{cmd}", "r") do |f|
        until f.eof? do
          c = f.getc
          putc c
          line << c
          if c == ?\n then
            self.feature_results << if RUBY_VERSION >= "1.9" then
                                      line.join
                                    else
                                      line.pack "c*"
                                    end
            line.clear
          end
        end
      end
    ensure
      $stdout.sync = old_sync
    end
    hook :ran_features
    self.feature_results = self.feature_results.join
    
    handle_feature_results(self.feature_results)
  end
  
  def handle_feature_results(results)
    # Run completed if we get to the final results.
    completed = results =~ /\d+ steps (passed|failed|skipped|pending)/
    return unless completed
    
    # Strategy: Find failing scenarios by color.  Since color is customizable,
    #           we need to find the colors for various statuses.
    
    color_by_status = lambda do |status|
      m = /^((?:\e\[\d+m)+)\d+ steps #{status}/.match(results)
      m && m[1]
    end
    passing_color = color_by_status["passed"]
    nonpassing_colors = %w{ failed skipped pending }.map(&color_by_status).compact
    
    if nonpassing_colors.empty? # nonpassing_colors is empty if all steps passed.
      failing_scenarios = []
    elsif passing_color.nil?    # passing_color is nil if no steps passed.
      failing_scenarios = :all
    else
      nonpassing_color_re = "(?:" + nonpassing_colors.map { |c| Regexp.escape(c) }.join("|") + ")"
    
      # Regexp matches scenarios and captures the scenario names
      failing_scenarios = results.scan(/^\s*#{Regexp.escape(passing_color)}\s*Scenario: (.+?)\e\[0m.*\n(?:.+\n)*(?:.*#{nonpassing_color_re}.+)(?:.+\n)*/).flatten
    end
    
    self.scenarios_to_run = failing_scenarios
    
    self.tainted = true unless self.scenarios_to_run == []
  end
  
  def make_cucumber_cmd(scenarios_to_run)
    return '' if scenarios_to_run == []
    
    args = File.exist?("cucumber.yml") ? %w{--profile autotest} : %w{-r features features}
    args << "--color"
    args = args.join(' ')
    
    if scenarios_to_run == :all
      scenario_args = nil
    else
      scenario_args = scenarios_to_run.map { |s| "-s '#{s}'" }.join(' ')
    end
    
    return "#{cucumber} #{args} #{scenario_args}"
  end
  
  def cucumber
    File.exist?("script/cucumber") ? "script/cucumber" : "cucumber"
  end
end