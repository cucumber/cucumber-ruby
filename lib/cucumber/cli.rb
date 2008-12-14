require 'optparse'
require 'cucumber'

module Cucumber
  class YmlLoadError < StandardError; end

  class CLI
    class << self
      attr_writer :step_mother, :executor, :features

      def execute(args)
        @execute_called = true
        parse(args).execute!(@step_mother, @executor, @features)
      end

      def execute_called?
        @execute_called
      end

      def parse(args)
        cli = new
        cli.parse_options!(args)
        cli
      end
    end

    attr_reader :options, :paths
    FORMATS = %w{pretty profile progress html autotest}
    DEFAULT_FORMAT = 'pretty'

    def initialize(out_stream = STDOUT, error_stream = STDERR)
      @out_stream = out_stream
      @error_stream = error_stream
      @paths = []
      @options = {
        :require => nil,
        :lang    => 'en',
        :dry_run => false,
        :source  => true,
        :snippets => true,
        :formats => {},
        :excludes => [],
        :scenario_names => nil
      }
      @active_format = DEFAULT_FORMAT
    end

    def parse_options!(args)
      @args = args
      return parse_args_from_profile('default') if args.empty?
      args.extend(OptionParser::Arguable)

      args.options do |opts|
        opts.banner = ["Usage: cucumber [options] [[FILE[:LINE[:LINE]*]] | [FILES|DIRS]]", "",
          "Examples:",
          "cucumber examples/i18n/en/features",
          "cucumber --language it examples/i18n/it/features/somma.feature:6:98:113", "", ""
        ].join("\n")
        opts.on("-r LIBRARY|DIR", "--require LIBRARY|DIR", "Require files before executing the features.",
          "If this option is not specified, all *.rb files that",
          "are siblings or below the features will be autorequired",
          "This option can be specified multiple times.") do |v|
          @options[:require] ||= []
          @options[:require] << v
        end
        opts.on("-s SCENARIO", "--scenario SCENARIO", "Only execute the scenario with the given name.",
                                                      "If this option is given more than once, run all",
                                                      "the specified scenarios.") do |v|
          @options[:scenario_names] ||= []
          @options[:scenario_names] << v
        end
        opts.on("-l LANG", "--language LANG", "Specify language for features (Default: #{@options[:lang]})",
          "Available languages: #{Cucumber.languages.join(", ")}",
          "Look at #{Cucumber::LANGUAGE_FILE} for keywords") do |v|
          @options[:lang] = v
        end
        opts.on("-f FORMAT", "--format FORMAT", "How to format features (Default: #{DEFAULT_FORMAT})",
          "Available formats: #{FORMATS.join(", ")}",
          "You can also provide your own formatter classes as long as they have been",
          "previously required using --require or if they are in the folder",
          "structure such that cucumber will require them automatically.",
          "This option can be specified multiple times.") do |v|
  
          @options[:formats][v] ||= []
          @options[:formats][v] << @out_stream
          @active_format = v
        end
        opts.on("-o", "--out FILE", "Write output to a file instead of @out_stream.",
          "This option can be specified multiple times, and applies to the previously",
          "specified --format.") do |v|
          @options[:formats][@active_format] ||= []
          if @options[:formats][@active_format].last == @out_stream
            @options[:formats][@active_format][-1] = File.open(v, 'w')
          else
            @options[:formats][@active_format] << File.open(v, 'w')
          end
        end
        opts.on("-c", "--[no-]color", "Use ANSI color in the output, if formatters use it.  If",
                                      "these options are given multiple times, the last one is",
                                      "used.  If neither --color or --no-color is given cucumber",
                                      "decides based on your platform and the output destination") do |v|
          @options[:color] = v
        end
        opts.on("-e", "--exclude PATTERN", "Don't run features matching a pattern") do |v|
          @options[:excludes] << v
        end
        opts.on("-p", "--profile PROFILE", "Pull commandline arguments from cucumber.yml.") do |v|
          parse_args_from_profile(v)
        end
        opts.on("-d", "--dry-run", "Invokes formatters without executing the steps.") do
          @options[:dry_run] = true
        end
        opts.on("-n", "--no-source", "Don't show the file and line of the step definition with the steps.") do
          @options[:source] = false
        end
        opts.on("-i", "--no-snippets", "Don't show the snippets for pending steps") do
          @options[:snippets] = false
        end
        opts.on("-q", "--quiet", "Don't show any development aid information") do
          @options[:snippets] = false
          @options[:source] = false
        end
        opts.on("-b", "--backtrace", "Show full backtrace for all errors") do
          Exception.cucumber_full_backtrace = true
        end
        opts.on("-v", "--verbose", "Show the files and features loaded") do
          @options[:verbose] = true
        end
        opts.on_tail("--version", "Show version") do
          @out_stream.puts VERSION::STRING
          Kernel.exit
        end
        opts.on_tail("--help", "You're looking at it") do
          @out_stream.puts opts.help
          Kernel.exit
        end
      end.parse!

      if @options[:formats].empty?
        @options[:formats][DEFAULT_FORMAT] = [@out_stream]
      end
      
      # Whatever is left after option parsing is the FILE arguments
      args = extract_and_store_line_numbers(args)
      @paths += args
    end


    def execute!(step_mother, executor, features)
      Term::ANSIColor.coloring = @options[:color] unless @options[:color].nil?
      Cucumber.load_language(@options[:lang])
      require_files
      enable_diffing
      executor.formatters = build_formatter_broadcaster(step_mother)
      load_plain_text_features(features)
      executor.lines_for_features = @options[:lines_for_features]
      executor.scenario_names = @options[:scenario_names] if @options[:scenario_names]
      executor.visit_features(features)
      exit 1 if executor.failed
    end

    private

    def extract_and_store_line_numbers(file_arguments)
      @options[:lines_for_features] = Hash.new{|k,v| k[v] = []}
      file_arguments.map do |arg|
        _, file, lines = */^([\w\W]*?):([\d:]+)$/.match(arg)
        unless file.nil?
          @options[:lines_for_features][file] += lines.split(':').map { |line| line.to_i }
          arg = file          
        end
        arg
      end
    end
   
    def cucumber_yml
      return @cucumber_yml if @cucumber_yml
      unless File.exist?('cucumber.yml')
        raise(YmlLoadError,"cucumber.yml was not found.  Please refer to cucumber's documentaion on defining profiles in cucumber.yml.  You must define a 'default' profile to use the cucumber command without any arguments.\nType 'cucumber --help' for usage.\n")
      end
      
      require 'yaml'
      begin
        @cucumber_yml = YAML::load(IO.read('cucumber.yml'))
      rescue Exception => e
        raise(YmlLoadError,"cucumber.yml was found, but could not be parsed. Please refer to cucumber's documentaion on correct profile usage.\n")
       end
     
      if @cucumber_yml.nil? || !@cucumber_yml.is_a?(Hash)
        raise(YmlLoadError,"cucumber.yml was found, but was blank or malformed. Please refer to cucumber's documentaion on correct profile usage.\n")
      end

      return @cucumber_yml
    end 

    def parse_args_from_profile(profile)
      unless cucumber_yml.has_key?(profile)
        return(exit_with_error <<-END_OF_ERROR)
Could not find profile: '#{profile}'

Defined profiles in cucumber.yml:
  * #{cucumber_yml.keys.join("\n  * ")}
        END_OF_ERROR
      end

      args_from_yml = cucumber_yml[profile] || ''

      if !args_from_yml.is_a?(String)
        exit_with_error "Profiles must be defined as a String.  The '#{profile}' profile was #{args_from_yml.inspect} (#{args_from_yml.class}).\n"
      elsif args_from_yml =~ /^\s*$/
        exit_with_error "The 'foo' profile in cucumber.yml was blank.  Please define the command line arguments for the 'foo' profile in cucumber.yml.\n"
      else
        parse_options!(args_from_yml.split(' '))
      end
      
    rescue YmlLoadError => e
      exit_with_error(e.message)
    end


    # Requires files - typically step files and ruby feature files.
    def require_files
      @args.clear # Shut up RSpec
      require "cucumber/treetop_parser/feature_#{@options[:lang]}"
      require "cucumber/treetop_parser/feature_parser"

      verbose_log("Ruby files required:")
      files_to_require.each do |lib|
        begin
          require lib
          verbose_log("  * #{lib}")
        rescue LoadError => e
          e.message << "\nFailed to load #{lib}"
          raise e
        end
      end
      verbose_log("\n")
    end
    
    def files_to_require
      requires = @options[:require] || feature_dirs
      files = requires.map do |path|
        path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
        File.directory?(path) ? Dir["#{path}/**/*.rb"] : path
      end.flatten.uniq
      files.sort { |a,b| (b =~ %r{/support/} || -1) <=>  (a =~ %r{/support/} || -1) }
    end

    def feature_files
      potential_feature_files = @paths.map do |path|
        path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
        path = path.chomp('/')
        File.directory?(path) ? Dir["#{path}/**/*.feature"] : path
      end.flatten.uniq

      @options[:excludes].each do |exclude|
        potential_feature_files.reject! do |path|
          path =~ /#{Regexp.escape(exclude)}/
        end
      end

      potential_feature_files
    end

    def feature_dirs
      feature_files.map{|f| File.directory?(f) ? f : File.dirname(f)}.uniq
    end

    def load_plain_text_features(features)
      parser = TreetopParser::FeatureParser.new

      verbose_log("Features:")
      feature_files.each do |f|
        features << parser.parse_feature(f)
        verbose_log("  * #{f}")
      end
      verbose_log("\n"*2)
    end

    def build_formatter_broadcaster(step_mother)
      formatter_broadcaster = Broadcaster.new
      @options[:formats].each do |format, output_list|
        output_broadcaster = build_output_broadcaster(output_list)
        case format
        when 'pretty'
          formatter_broadcaster.register(Formatters::PrettyFormatter.new(output_broadcaster, step_mother, @options))
        when 'progress'
          formatter_broadcaster.register(Formatters::ProgressFormatter.new(output_broadcaster))
        when 'profile'
          formatter_broadcaster.register(Formatters::ProfileFormatter.new(output_broadcaster, step_mother))
        when 'html'
          formatter_broadcaster.register(Formatters::HtmlFormatter.new(output_broadcaster, step_mother))
        when 'autotest'
          formatter_broadcaster.register(Formatters::AutotestFormatter.new(output_broadcaster))
        else
          begin
            formatter_class = constantize(format)
            formatter_broadcaster.register(formatter_class.new(output_broadcaster, step_mother, @options))
          rescue NameError => e
            @error_stream.puts "Invalid format: #{format}\n"
            exit_with_help
          rescue Exception => e
            exit_with_error("Error creating formatter: #{format}\n#{e}\n")
          end
        end
      end
      formatter_broadcaster
    end

    def build_output_broadcaster(output_list)
      output_broadcaster = Broadcaster.new
      output_list.each do |output|
        output_broadcaster.register(output)
      end
      output_broadcaster
    end
    
  private

    def constantize(camel_cased_word)
      names = camel_cased_word.split('::')
      names.shift if names.empty? || names.first.empty?

      constant = Object
      names.each do |name|
        constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
      end
      constant
    end
    
    def verbose_log(string)
      @out_stream.puts(string) if @options[:verbose]
    end

    def exit_with_help
      parse_options!(%w{--help})
    end

    def exit_with_error(error_message)
      @error_stream << error_message
      Kernel.exit 1
    end

    def enable_diffing
      if defined?(::Spec)
        require 'spec/expectations/differs/default'
        options = ::Spec::Runner::Options.new(nil, nil)
        ::Spec::Expectations.differ = ::Spec::Expectations::Differs::Default.new(options)
      end
    end
  end
end

extend Cucumber::StepMethods
Cucumber::CLI.step_mother = step_mother
Cucumber::CLI.executor = executor

extend Cucumber::Tree
Cucumber::CLI.features = features
