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
  module FixRuby21Bug9285
    def message
      String(super).gsub("@ rb_sysopen ", "")
    end
  end

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
    include FixRuby21Bug9285 if Cucumber::RUBY_2_1
  end

  require 'cucumber/core'
  require 'cucumber/runtime/user_interface'
  require 'cucumber/runtime/results'
  require 'cucumber/runtime/support_code'
  require 'cucumber/runtime/tag_limits'
  class Runtime
    attr_reader :results, :support_code, :configuration

    include Cucumber::Core
    include Formatter::Duration
    include Runtime::UserInterface

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
      fire_after_configuration_hook
      self.visitor = report

      execute features, mappings, report, filters
    end

    def features_paths
      @configuration.paths
    end

    def dry_run?
      @configuration.dry_run?
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

    def snippet_text(step_keyword, step_name, multiline_arg) #:nodoc:
      @support_code.snippet_text(::Gherkin::I18n.code_keyword_for(step_keyword), step_name, multiline_arg)
    end

    def with_hooks(scenario, skip_hooks=false)
      fail 'deprecated'
      around(scenario, skip_hooks) do
        before_and_after(scenario, skip_hooks) do
          yield scenario
        end
      end
    end

    def around(scenario, skip_hooks=false, &block) #:nodoc:
      fail 'deprecated'
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

    def begin_scenario(scenario)
      @support_code.fire_hook(:begin_scenario, scenario)
    end

    def before(scenario) #:nodoc:
      fail 'deprecated'
      return if dry_run? || @current_scenario
      @current_scenario = scenario
      @support_code.fire_hook(:before, scenario)
    end

    def after(scenario) #:nodoc:
      fail 'deprecated'
      @current_scenario = nil
      return if dry_run?
      @support_code.fire_hook(:after, scenario)
    end

    def after_step #:nodoc:
      return if dry_run?
      @support_code.fire_hook(:execute_after_step, @current_scenario)
    end

    def unknown_programming_language?
      @support_code.unknown_programming_language?
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
      @mappings = Mappings.for(self)
    end

    require 'cucumber/reports/legacy_formatter'
    def report
      @report ||= Cucumber::Reports::LegacyFormatter.new(self, @configuration.formatters(self))
    end

    require 'cucumber/core/test/filters'
    def filters
      tag_expressions = @configuration.tag_expressions
      name_regexps = @configuration.name_regexps
      tag_limits = @configuration.tag_limits
      [].tap do |filters|
        filters << [Cucumber::Runtime::Randomizer, [@configuration.seed]] if @configuration.randomize?
        filters << [Cucumber::Runtime::TagLimits::Filter, [tag_limits]] if tag_limits.any?
        filters << [Cucumber::Core::Test::TagFilter, [tag_expressions]]
        filters << [Cucumber::Core::Test::NameFilter, [name_regexps]]
        filters << [Cucumber::Core::Test::LocationsFilter, [filespecs.locations]]
        filters << [Quit, []]
      end
    end

    class Randomizer
      def initialize(seed, receiver)
        @receiver = receiver
        @test_cases = []
        @seed = seed
      end

      def test_case(test_case)
        @test_cases << test_case
      end

      def done
        shuffled_test_cases.each do |test_case|
          test_case.describe_to(@receiver)
        end
        @receiver.done
      end

      private

      def shuffled_test_cases
        @test_cases.shuffle(random: Random.new(seed))
      end

      attr_reader :seed
      private :seed
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

      def done
        @receiver.done
        self
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

end
