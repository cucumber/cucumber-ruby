require 'autotest'
require 'tempfile'
require File.dirname(__FILE__) + '/../cucumber/platform'

module Autotest::CucumberMixin
  def self.included(receiver)
    receiver::ALL_HOOKS << [:run_features, :ran_features]
  end
  
  attr_accessor :scenarios_to_run
  
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
    
  def run_features
    hook :run_features
    Tempfile.open('autotest-cucumber') do |dirty_scenarios_file|
      cmd = self.make_cucumber_cmd self.scenarios_to_run, dirty_scenarios_file.path
      return if cmd.empty?
      puts cmd unless $q
      old_sync = $stdout.sync
      $stdout.sync = true
      self.results = []
      line = []
      begin
        open("| #{cmd}", "r") do |f|
          until f.eof? do
            c = f.getc
            putc c
            line << c
            if c == ?\n then
              self.results << if RUBY_VERSION >= "1.9" then
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
      self.scenarios_to_run = dirty_scenarios_file.readlines.map { |l| l.chomp }
      self.tainted = true unless self.scenarios_to_run == []
    end
    hook :ran_features
  end
  
  def make_cucumber_cmd(scenarios_to_run, dirty_scenarios_filename)
    return '' if scenarios_to_run == []
    
    profiles = YAML.load_file("cucumber.yml").keys rescue []
    
    profile ||= "autotest-all" if profiles.include?("autotest-all") and scenarios_to_run == :all
    profile ||= "autotest"     if profiles.include?("autotest")
    profile ||= nil
    
    if profile
      args = ["--profile", profile]
    else
      args = %w{features --format} << (scenarios_to_run == :all ? "progress" : "pretty")
    end
    args += %w{--format autotest --color --out} << dirty_scenarios_filename
    args = args.join(' ')
    
    if scenarios_to_run == :all
      scenario_args = nil
    else
      scenario_args = scenarios_to_run.map { |s| "-s '#{s}'" }.join(' ')
    end
    return "#{$CUCUMBER_RUBY} #{cucumber} #{args} #{scenario_args}"
  end
  
  def cucumber
    File.file?("script/cucumber") ? "script/cucumber" : "cucumber"
  end
end