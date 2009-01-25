require 'optparse'
require 'cucumber'
require 'ostruct'
require 'cucumber/parser'
require 'cucumber/formatter'

module Cucumber
  class YmlLoadError < StandardError; end

  class CLI
    class << self
      def step_mother=(step_mother)
        @step_mother = step_mother
        @step_mother.extend(StepMother)
        @step_mother.snippet_generator = StepDefinition
      end

      def execute(args)
        parse(args).execute!(@step_mother)
      end

      def parse(args)
        cli = new
        cli.parse_options!(args)
        cli
      end
    end

    attr_reader :options, :paths
    FORMATS = %w{pretty profile progress rerun}
    DEFAULT_FORMAT = 'pretty'

    def initialize(out_stream = STDOUT, error_stream = STDERR)
      @out_stream = out_stream

      @error_stream = error_stream
      @paths = []
      @options = {
        :strict   => false,
        :require  => nil,
        :lang     => 'en',
        :dry_run  => false,
        :formats  => {},
        :excludes => [],
        :tags     => [],
        :scenario_names => []
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
        opts.on("-r LIBRARY|DIR", "--require LIBRARY|DIR", 
          "Require files before executing the features. If this",
          "option is not specified, all *.rb files that are",
          "siblings or below the features will be loaded auto-",
          "matically. Automatic loading is disabled when this",
          "option is specified, and all loading becomes explicit.",
          "Files under directories named \"support\" are always",
          "loaded first.",
          "This option can be specified multiple times.") do |v|
          @options[:require] ||= []
          @options[:require] << v
        end
        opts.on("-l LANG", "--language LANG", 
          "Specify language for features (Default: #{@options[:lang]})",
          %{Run with "--language help" to see all languages},
          %{Run with "--language LANG help" to list keywords for LANG}) do |v|
          if v == 'help'
            list_languages
          elsif args==['help']
            list_keywords(v)
          else
            @options[:lang] = v
          end
        end
        opts.on("-f FORMAT", "--format FORMAT", 
          "How to format features (Default: #{DEFAULT_FORMAT})",
          "Available formats: #{FORMATS.join(", ")}",
          "You can also provide your own formatter classes as long",
          "as they have been previously required using --require or",
          "if they are in the folder structure such that cucumber",
          "will require them automatically.", 
          "This option can be specified multiple times.") do |v|
          @options[:formats][v] = @out_stream
          @active_format = v
        end
        opts.on("-o", "--out FILE", 
          "Write output to a file instead of STDOUT. This option",
          "applies to the previously specified --format, or the",
          "default format if no format is specified.") do |v|
          @options[:formats][@active_format] = v
        end
        opts.on("-t TAGS", "--tags TAGS", 
          "Only execute the features or scenarios with the specified tags.",
          "TAGS must be comma-separated without spaces.") do |v|
          @options[:tags] = v.split(",")
        end
        opts.on("-s SCENARIO", "--scenario SCENARIO", 
          "Only execute the scenario with the given name. If this option",
          "is given more than once, run all the specified scenarios.") do |v|
          @options[:scenario_names] << v
        end
        opts.on("-e", "--exclude PATTERN", "Don't run feature files matching PATTERN") do |v|
          @options[:excludes] << v
        end
        opts.on("-p", "--profile PROFILE", "Pull commandline arguments from cucumber.yml.") do |v|
          parse_args_from_profile(v)
        end
        opts.on("-c", "--[no-]color",
          "Whether or not to use ANSI color in the output. Cucumber decides",
          "based on your platform and the output destination if not specified.") do |v|
          Term::ANSIColor.coloring = v
        end
        opts.on("-d", "--dry-run", "Invokes formatters without executing the steps.",
          "Implies --quiet.") do
          @options[:dry_run] = true
          @quiet = true
        end
        opts.on("-a", "--autoformat DIRECTORY", 
          "Reformats (pretty prints) feature files and write them to DIRECTORY.",
          "Be careful if you choose to overwrite the originals.",
          "Implies --dry-run --formatter pretty.") do |directory|
          @options[:autoformat] = directory
          Term::ANSIColor.coloring = false
          @options[:dry_run] = true
          @quiet = true
        end
        opts.on("-m", "--[no-]multiline", 
          "Don't print multiline strings and tables under steps.") do |v|
          @options[:source] = v
        end
        opts.on("-n", "--[no-]source", 
          "Don't show the file and line of the step definition with the steps.") do |v|
          @options[:source] = v
        end
        opts.on("-i", "--[no-]snippets", "Don't show the snippets for pending steps.") do |v|
          @options[:snippets] = v
        end
        opts.on("-q", "--quiet", "Alias for --no-snippets --no-source.") do
          @quiet = true
        end
        opts.on("-b", "--backtrace", "Show full backtrace for all errors.") do
          Exception.cucumber_full_backtrace = true
        end
        opts.on("--strict", "Fail if there are any undefined steps.") do
          @options[:strict] = true
        end
        opts.on("-v", "--verbose", "Show the files and features loaded.") do
          @options[:verbose] = true
        end
        opts.on_tail("--version", "Show version.") do
          @out_stream.puts VERSION::STRING
          Kernel.exit
        end
        opts.on_tail("--help", "You're looking at it.") do
          @out_stream.puts opts.help
          Kernel.exit
        end
      end.parse!

      @options[:formats]['pretty'] = @out_stream if @options[:formats].empty?

      @options[:snippets] = true if !@quiet && @options[:snippets].nil?
      @options[:source]   = true if !@quiet && @options[:source].nil?

      # Whatever is left after option parsing is the FILE arguments
      @paths += args
    end


    def execute!(step_mother)
      Cucumber.load_language(@options[:lang])
      require_files
      enable_diffing
      features = load_plain_text_features

      visitor = build_formatter_broadcaster(step_mother)
      visitor.options = @options
      visitor.visit_features(features)
      
      failure = features.steps[:failed].any? || (@options[:strict] && features.steps[:undefined].length)
      Kernel.exit(failure ? 1 : 0)
    end

    private

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

    def load_plain_text_features
      filter = Ast::Filter.new(@options)
      features = Ast::Features.new(filter)
      parser = Parser::FeatureParser.new

      verbose_log("Features:")
      feature_files.each do |f|
        features.add_feature(parser.parse_file(f))
        verbose_log("  * #{f}")
      end
      verbose_log("\n"*2)
      features
    end

    def build_formatter_broadcaster(step_mother)
      return Formatter::Pretty.new(step_mother, nil, @options) if @options[:autoformat]
      formatters = @options[:formats].map do |format, out|
        if String === out # file name
          out = File.open(out, Cucumber.file_mode('w'))
          at_exit do
            out.flush
            out.close
          end
        end

        case format
        when 'pretty'
          Formatter::Pretty.new(step_mother, out, @options)
        when 'progress'
          Formatter::Progress.new(step_mother, out, @options)
        when 'profile'
          Formatter::Profile.new(step_mother, out, @options)
        when 'rerun'
          Formatter::Rerun.new(step_mother, out, @options)
        else
          begin
            formatter_class = constantize(format)
            formatter_class.new(step_mother, out, @options)
          rescue Exception => e
            exit_with_error("Error creating formatter: #{format}", e)
          end
        end
      end
      Broadcaster.new(formatters)
    end

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

    def exit_with_error(error_message, e=nil)
      @error_stream.puts(error_message)
      if e
        @error_stream.puts("#{e.message} (#{e.class})")
        @error_stream.puts(e.backtrace.join("\n"))
      end
      Kernel.exit 1
    end

    def enable_diffing
      if defined?(::Spec)
        require 'spec/expectations/differs/default'
        options = OpenStruct.new(:diff_format => :unified, :context_lines => 3)
        ::Spec::Expectations.differ = ::Spec::Expectations::Differs::Default.new(options)
      end
    end

    def list_languages
      raw = Cucumber::LANGUAGES.keys.sort.map do |lang|
        [lang, Cucumber::LANGUAGES[lang]['name'], Cucumber::LANGUAGES[lang]['native']]
      end
      print_lang_table(raw, {:check_lang=>true})
    end

    def list_keywords(lang)
      unless Cucumber::LANGUAGES[lang]
        exit_with_error("No language with key #{v}")
      end
      raw = Cucumber::KEYWORD_KEYS.map do |key|
        [key, Cucumber::LANGUAGES[lang][key]]
      end
      print_lang_table(raw, {})
    end
    
    def print_lang_table(raw, options)
      table = Ast::Table.new(raw)
      formatter = Formatter::Pretty.new(nil, @out_stream, options, '')

      def formatter.visit_table_row(table_row, status)
        @col = 1
        super
      end

      def formatter.visit_table_cell_value(value, width, status)
        if @col == 1
          if(@options[:check_lang])
            @incomplete = Cucumber.language_complete?(value)
          end
          status = :comment 
        elsif @incomplete
          status = :failed
        end
        
        @col += 1
        super(value, width, status)
      end

      formatter.indent = 0
      formatter.visit_multiline_arg(table, :passed)
      Kernel.exit
    end
  end
end

Cucumber::CLI.step_mother = self
