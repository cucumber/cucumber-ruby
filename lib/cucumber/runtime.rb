# -*- coding: utf-8 -*-
require 'fileutils'
require 'multi_json'
require 'multi_test'
require 'gherkin/rubify'
require 'gherkin/i18n'
require 'cucumber/configuration'
require 'cucumber/load_path'
require 'cucumber/language_support/language_methods'
require 'cucumber/formatter/duration'
require 'cucumber/file_specs'

module Cucumber
  class FileException < Exception
    attr :path

    def initialize(original_exception, path)
      super(original_exception)
      @path = path
    end
  end

  class FileNotFoundException < FileException
  end

  class FeatureFolderNotFoundException < FileException
  end

  # This is the meaty part of Cucumber that ties everything together.
  require 'cucumber/core'
  class NewRuntime
    attr_reader :results, :support_code

    include Cucumber::Core
    include Formatter::Duration

    def initialize(configuration = Configuration.default)
      @current_scenario = nil
      @configuration = Configuration.parse(configuration)
      @support_code = SupportCode.new(self, @configuration)
      @results = Results.new(@configuration)
    end

    # Allows you to take an existing runtime and change it's configuration
    def configure(new_configuration)
      @configuration = Configuration.parse(new_configuration)
      @support_code.configure(@configuration)
      @results.configure(@configuration)
    end

    def load_programming_language(language)
      @support_code.load_programming_language(language)
    end

    require 'cucumber/core/test/tag_filter'
    def run!
      load_step_definitions
      fire_after_configuration_hook
      self.visitor = report

      execute features, mappings, report, filters
      report.after_suite
    end

    def features_paths
      @configuration.paths
    end

    def step_visited(step) #:nodoc:
      @results.step_visited(step)
    end

    def scenarios(status = nil)
      @results.scenarios(status)
    end

    def steps(status = nil)
      @results.steps(status)
    end

    def step_match(step_name, name_to_report=nil) #:nodoc:
      @support_code.step_match(step_name, name_to_report)
    end

    def unmatched_step_definitions
      @support_code.unmatched_step_definitions
    end

    def snippet_text(step_keyword, step_name, multiline_arg_class) #:nodoc:
      @support_code.snippet_text(::Gherkin::I18n.code_keyword_for(step_keyword), step_name, multiline_arg_class)
    end

    def with_hooks(scenario, skip_hooks=false)
      around(scenario, skip_hooks) do
        before_and_after(scenario, skip_hooks) do
          yield scenario
        end
      end
    end

    def around(scenario, skip_hooks=false, &block) #:nodoc:
      if skip_hooks
        yield
        return
      end

      @support_code.around(scenario, block)
    end

    def before_and_after(scenario, skip_hooks=false) #:nodoc:
      before(scenario) unless skip_hooks
      yield scenario
      after(scenario) unless skip_hooks
      record_result scenario
    end

    def record_result(scenario)
      @results.scenario_visited(scenario)
    end

    def before(scenario) #:nodoc:
      return if @configuration.dry_run? || @current_scenario
      @current_scenario = scenario
      @support_code.fire_hook(:before, scenario)
    end

    def after(scenario) #:nodoc:
      @current_scenario = nil
      return if @configuration.dry_run?
      @support_code.fire_hook(:after, scenario)
    end

    def after_step #:nodoc:
      return if @configuration.dry_run?
      @support_code.fire_hook(:execute_after_step, @current_scenario)
    end

    def unknown_programming_language?
      @support_code.unknown_programming_language?
    end

    # TODO: this code is untested
    def write_stepdefs_json
      if(@configuration.dotcucumber)
        stepdefs = []
        @support_code.step_definitions.sort{|a,b| a.to_hash['source'] <=> a.to_hash['source']}.each do |stepdef|
          stepdef_hash = stepdef.to_hash
          steps = []
          features.each do |feature|
            feature.feature_elements.each do |feature_element|
              feature_element.raw_steps.each do |step|
                args = stepdef.arguments_from(step.name)
                if(args)
                  steps << {
                    'name' => step.name,
                    'args' => args.map do |arg|
                      {
                        'offset' => arg.offset,
                        'val' => arg.val
                      }
                    end
                  }
                end
              end
            end
          end
          stepdef_hash['file_colon_line'] = stepdef.file_colon_line
          stepdef_hash['steps'] = steps.uniq.sort {|a,b| a['name'] <=> b['name']}
          stepdefs << stepdef_hash
        end
        if !File.directory?(@configuration.dotcucumber)
          FileUtils.mkdir_p(@configuration.dotcucumber)
        end
        File.open(File.join(@configuration.dotcucumber, 'stepdefs.json'), 'w') do |io|
          io.write(MultiJson.dump(stepdefs, :pretty => true))
        end
      end
    end

    # Returns Ast::DocString for +string_without_triple_quotes+.
    #
    def doc_string(string_without_triple_quotes, content_type='', line_offset=0)
      file, line = *caller[0].split(':')[0..1]
      location = Core::Ast::Location.new(file, line)
      Core::Ast::DocString.new(string_without_triple_quotes, content_type, location)
    end

  private

    def fire_after_configuration_hook #:nodoc
      @support_code.fire_hook(:after_configuration, @configuration)
    end

    require 'cucumber/core/gherkin/document'
    def features
      @features ||= feature_files.map do |path|
        source = NormalisedEncodingFile.read(path)
        Cucumber::Core::Gherkin::Document.new(path, source)
      end
    end

    def feature_files
      filespecs.files
    end

    def filespecs
      @filespecs ||= FileSpecs.new(@configuration.feature_files)
    end

    class NormalisedEncodingFile
      COMMENT_OR_EMPTY_LINE_PATTERN = /^\s*#|^\s*$/ #:nodoc:
      ENCODING_PATTERN = /^\s*#\s*encoding\s*:\s*([^\s]+)/ #:nodoc:

      def self.read(path)
        new(path).read
      end

      def initialize(path)
        begin
          @file = File.new(path)
          set_encoding
        rescue Errno::EACCES => e
          raise FileNotFoundException.new(e, File.expand_path(path))
        rescue Errno::ENOENT => e
          raise FeatureFolderNotFoundException.new(e, path)
        end
      end

      def read
        @file.read.encode("UTF-8")
      end

      private

      def set_encoding
        @file.each do |line|
          if ENCODING_PATTERN =~ line
            @file.set_encoding $1
            break
          end
          break unless COMMENT_OR_EMPTY_LINE_PATTERN =~ line
        end
        @file.rewind
      end
    end

    require 'cucumber/mappings'
    def mappings
      @mappings = Mappings.new(self)
    end

    require 'cucumber/formatter/report_adapter'
    def report
      @report ||= Cucumber::Formatter::ReportAdapter.new(self, @configuration.formatters(self).first)
    end

    def filters
      tag_expressions = @configuration.tag_expressions
      [
        [Cucumber::Core::Test::TagFilter, [tag_expressions]],
        [LocationFilter, [filespecs.locations]],
        [Quit, []],
      ]
    end

    class LocationFilter
      def initialize(locations, receiver)
        @receiver = receiver
        @locations = locations
      end

      def test_case(test_case)
        if test_case.match_locations?(@locations)
          test_case.describe_to @receiver
        end
      end
    end

    class Quit
      def initialize(receiver)
        @receiver = receiver
      end

      def test_case(test_case)
        unless Cucumber.wants_to_quit
          test_case.describe_to @receiver
        end
      end
    end

    def load_step_definitions
      files = @configuration.support_to_load + @configuration.step_defs_to_load
      @support_code.load_files!(files)
    end

    def log
      Cucumber.logger
    end

  end

  class LegacyRuntime
    attr_reader :results, :support_code

    include Formatter::Duration

    def initialize(configuration = Configuration.default)
      @current_scenario = nil
      @configuration = Configuration.parse(configuration)
      @support_code = SupportCode.new(self, @configuration)
      @results = Results.new(@configuration)
    end

    # Allows you to take an existing runtime and change it's configuration
    def configure(new_configuration)
      @configuration = Configuration.parse(new_configuration)
      @support_code.configure(@configuration)
      @results.configure(@configuration)
    end

    def load_programming_language(language)
      @support_code.load_programming_language(language)
    end

    def run!
      load_step_definitions
      disable_minitest_test_unit_autorun
      fire_after_configuration_hook

      tree_walker = @configuration.build_tree_walker(self)
      self.visitor = tree_walker # Ugly circular dependency, but needed to support World#puts

      features.accept(tree_walker)
    end

    def features_paths
      @configuration.paths
    end

    def step_visited(step) #:nodoc:
      @results.step_visited(step)
    end

    def scenarios(status = nil)
      @results.scenarios(status)
    end

    def steps(status = nil)
      @results.steps(status)
    end

    def step_match(step_name, name_to_report=nil) #:nodoc:
      @support_code.step_match(step_name, name_to_report)
    end

    def unmatched_step_definitions
      @support_code.unmatched_step_definitions
    end

    def snippet_text(step_keyword, step_name, multiline_arg_class) #:nodoc:
      @support_code.snippet_text(Gherkin::I18n.code_keyword_for(step_keyword), step_name, multiline_arg_class)
    end

    def with_hooks(scenario, skip_hooks=false)
      around(scenario, skip_hooks) do
        before_and_after(scenario, skip_hooks) do
          yield scenario
        end
      end
    end

    def around(scenario, skip_hooks=false, &block) #:nodoc:
      if skip_hooks
        yield
        return
      end

      @support_code.around(scenario, block)
    end

    def before_and_after(scenario, skip_hooks=false) #:nodoc:
      before(scenario) unless skip_hooks
      yield scenario
      after(scenario) unless skip_hooks
      record_result scenario
    end

    def record_result(scenario)
      @results.scenario_visited(scenario)
    end

    def before(scenario) #:nodoc:
      return if @configuration.dry_run? || @current_scenario
      @current_scenario = scenario
      @support_code.fire_hook(:before, scenario)
    end

    def after(scenario) #:nodoc:
      @current_scenario = nil
      return if @configuration.dry_run?
      @support_code.fire_hook(:after, scenario)
    end

    def after_step #:nodoc:
      return if @configuration.dry_run?
      @support_code.fire_hook(:execute_after_step, @current_scenario)
    end

    def unknown_programming_language?
      @support_code.unknown_programming_language?
    end

    # TODO: this code is untested
    def write_stepdefs_json
      if(@configuration.dotcucumber)
        stepdefs = []
        @support_code.step_definitions.sort{|a,b| a.to_hash['source'] <=> a.to_hash['source']}.each do |stepdef|
          stepdef_hash = stepdef.to_hash
          steps = []
          features.each do |feature|
            feature.feature_elements.each do |feature_element|
              feature_element.raw_steps.each do |step|
                args = stepdef.arguments_from(step.name)
                if(args)
                  steps << {
                    'name' => step.name,
                    'args' => args.map do |arg|
                      {
                        'offset' => arg.offset,
                        'val' => arg.val
                      }
                    end
                  }
                end
              end
            end
          end
          stepdef_hash['file_colon_line'] = stepdef.file_colon_line
          stepdef_hash['steps'] = steps.uniq.sort {|a,b| a['name'] <=> b['name']}
          stepdefs << stepdef_hash
        end
        if !File.directory?(@configuration.dotcucumber)
          FileUtils.mkdir_p(@configuration.dotcucumber)
        end
        File.open(File.join(@configuration.dotcucumber, 'stepdefs.json'), 'w') do |io|
          io.write(MultiJson.dump(stepdefs, :pretty => true))
        end
      end
    end

    # Returns Ast::DocString for +string_without_triple_quotes+.
    #
    def doc_string(string_without_triple_quotes, content_type='', line_offset=0)
      Ast::DocString.new(string_without_triple_quotes,content_type)
    end

  private

    def fire_after_configuration_hook #:nodoc
      @support_code.fire_hook(:after_configuration, @configuration)
    end

    def features
      @loader ||= Runtime::FeaturesLoader.new(
        @configuration.feature_files,
        @configuration.filters,
        @configuration.tag_expression)
      @loader.features
    end

    def load_step_definitions
      files = @configuration.support_to_load + @configuration.step_defs_to_load
      @support_code.load_files!(files)
    end

    def disable_minitest_test_unit_autorun
      MultiTest.disable_autorun
    end

    def log
      Cucumber.logger
    end
  end

  Runtime = ENV['USE_LEGACY'] ? LegacyRuntime : NewRuntime
  require 'cucumber/runtime/user_interface'
  require 'cucumber/runtime/features_loader'
  require 'cucumber/runtime/results'
  require 'cucumber/runtime/support_code'

  class Runtime
    include Runtime::UserInterface
  end
end
