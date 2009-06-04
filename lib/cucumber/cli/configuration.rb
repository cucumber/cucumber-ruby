module Cucumber
  module Cli
    class YmlLoadError < StandardError; end

    class Configuration
      BUILTIN_FORMATS = {
        'html'     => 'Cucumber::Formatter::Html',
        'pretty'   => 'Cucumber::Formatter::Pretty',
        'profile'  => 'Cucumber::Formatter::Profile',
        'progress' => 'Cucumber::Formatter::Progress',
        'rerun'    => 'Cucumber::Formatter::Rerun',
        'usage'    => 'Cucumber::Formatter::Usage',
        'junit'    => 'Cucumber::Formatter::Junit'
      }
      DEFAULT_FORMAT = 'pretty'
      DRB_FLAG = '--drb'
      PROFILE_SHORT_FLAG = '-p'
      PROFILE_LONG_FLAG = '--profile'

      attr_reader :paths
      attr_reader :options

      def initialize(out_stream = STDOUT, error_stream = STDERR)
        @out_stream   = out_stream
        @error_stream = error_stream

        @paths          = []
        @options        = default_options

        @active_format  = DEFAULT_FORMAT
      end

      def parse!(args)
        @args = args.empty? ? args_from_profile('default') : args
        expand_profiles_into_args
        return if parse_drb

        @args.extend(::OptionParser::Arguable)

        @args.options do |opts|
          opts.banner = ["Usage: cucumber [options] [ [FILE|DIR|URL][:LINE[:LINE]*] ]+", "",
            "Examples:",
            "cucumber examples/i18n/en/features",
            "cucumber --language it examples/i18n/it/features/somma.feature:6:98:113",
            "cucumber -s -i http://rubyurl.com/eeCl", "", "",
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
              list_languages_and_exit
            elsif args==['help']
              list_keywords_and_exit(v)
            else
              @options[:lang] = v
            end
          end
          opts.on("-f FORMAT", "--format FORMAT",
            "How to format features (Default: #{DEFAULT_FORMAT})",
            "Available formats: #{BUILTIN_FORMATS.keys.sort.join(", ")}",
            "FORMAT can also be the fully qualified class name of",
            "your own custom formatter. If the class isn't loaded,",
            "Cucumber will attempt to require a file with a relative",
            "file name that is the underscore name of the class name.",
            "Example: --format Foo::BarZap -> Cucumber will look for",
            "foo/bar_zap.rb. You can place the file with this relative",
            "path underneath your features/support directory or anywhere",
            "on Ruby's LOAD_PATH, for example in a Ruby gem.") do |v|
            @options[:formats][v] = @out_stream
            @active_format = v
          end
          opts.on("-o", "--out [FILE|DIR]",
            "Write output to a file/directory instead of STDOUT. This option",
            "applies to the previously specified --format, or the",
            "default format if no format is specified. Check the specific",
            "formatter's docs to see whether to pass a file or a dir.") do |v|
            @options[:formats][@active_format] = v
          end
          opts.on("-t TAGS", "--tags TAGS",
            "Only execute the features or scenarios with the specified tags.",
            "TAGS must be comma-separated without spaces. Prefix tags with ~ to",
            "exclude features or scenarios having that tag. Tags can be specified",
            "with or without the @ prefix.") do |v|
            @options[:include_tags], @options[:exclude_tags] = *parse_tags(v)
          end
          opts.on("-n NAME", "--name NAME",
            "Only execute the feature elements which match part of the given name.",
            "If this option is given more than once, it will match against all the",
            "given names.") do |v|
            @options[:name_regexps] << /#{v}/
          end
          opts.on("-e", "--exclude PATTERN", "Don't run feature files or require ruby files matching PATTERN") do |v|
            @options[:excludes] << Regexp.new(v)
          end
          opts.on(PROFILE_SHORT_FLAG, "#{PROFILE_LONG_FLAG} PROFILE", "Pull commandline arguments from cucumber.yml.") do |v|
            # Processing of this is done previsouly so that the DRb flag can be detected within profiles.
          end
          opts.on("-c", "--[no-]color",
            "Whether or not to use ANSI color in the output. Cucumber decides",
            "based on your platform and the output destination if not specified.") do |v|
            Term::ANSIColor.coloring = v
          end
          opts.on("-d", "--dry-run", "Invokes formatters without executing the steps.",
            "This also omits the loading of your support/env.rb file if it exists.",
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
          opts.on("-m", "--no-multiline",
            "Don't print multiline strings and tables under steps.") do
            @options[:no_multiline] = true
          end
          opts.on("-s", "--no-source",
            "Don't print the file and line of the step definition with the steps.") do
            @options[:source] = false
          end
          opts.on("-i", "--no-snippets", "Don't print snippets for pending steps.") do
            @options[:snippets] = false
          end
          opts.on("-q", "--quiet", "Alias for --no-snippets --no-source.") do
            @quiet = true
          end
          opts.on("-b", "--backtrace", "Show full backtrace for all errors.") do
            Exception.cucumber_full_backtrace = true
          end
          opts.on("-S", "--strict", "Fail if there are any undefined steps.") do
            @options[:strict] = true
          end
          opts.on("-w", "--wip", "Fail if there are any passing scenarios.") do
            @options[:wip] = true
          end
          opts.on("-v", "--verbose", "Show the files and features loaded.") do
            @options[:verbose] = true
          end
          opts.on("-g", "--guess", "Guess best match for Ambiguous steps.") do
            @options[:guess] = true
          end
          opts.on("-x", "--expand", "Expand Scenario Outline Tables in output.") do
            @options[:expand] = true
          end
          opts.on("--no-diff", "Disable diff output on failing expectations.") do
            @options[:diff_enabled] = false
          end
          opts.on(DRB_FLAG, "Run features against a DRb server. (i.e. with the spork gem)") do
            # Processing of this is done previsouly in order to short circuit args from being lost.
          end
          opts.on_tail("--version", "Show version.") do
            @out_stream.puts VERSION::STRING
            Kernel.exit
          end
          opts.on_tail("-h", "--help", "You're looking at it.") do
            @out_stream.puts opts.help
            Kernel.exit
          end
        end.parse!

        @options[:formats]['pretty'] = @out_stream if @options[:formats].empty?

        @options[:snippets] = true if !@quiet && @options[:snippets].nil?
        @options[:source]   = true if !@quiet && @options[:source].nil?

        raise("You can't use both --strict and --wip") if @options[:strict] && @options[:wip]

        # Whatever is left after option parsing is the FILE arguments
        @paths += @args
      end

      def verbose?
        @options[:verbose]
      end

      def strict?
        @options[:strict]
      end

      def wip?
        @options[:wip]
      end

      def guess?
        @options[:guess]
      end

      def diff_enabled?
        @options[:diff_enabled]
      end

      def drb?
        @drb
      end

      def load_language
        if Cucumber.language_incomplete?(@options[:lang])
          list_keywords_and_exit(@options[:lang])
        else
          Cucumber.load_language(@options[:lang])
        end
      end

      def parse_tags(tag_string)
        tag_names = tag_string.split(",")
        excludes, includes = tag_names.partition{|tag| tag =~ /^~/}
        excludes = excludes.map{|tag| tag[1..-1]}

        # Strip @
        includes = includes.map{|tag| Ast::Tags.strip_prefix(tag)}
        excludes = excludes.map{|tag| Ast::Tags.strip_prefix(tag)}
        [includes, excludes]
      end

      def build_formatter_broadcaster(step_mother)
        return Formatter::Pretty.new(step_mother, nil, @options) if @options[:autoformat]
        formatters = @options[:formats].map do |format, out|
          if String === out # file name
            unless File.directory?(out)
              out = File.open(out, Cucumber.file_mode('w'))
              at_exit do
                out.flush
                out.close
              end
            end
          end

          begin
            formatter_class = formatter_class(format)
            formatter_class.new(step_mother, out, @options)
          rescue Exception => e
            e.message << "\nError creating formatter: #{format}"
            raise e
          end
        end

        broadcaster = Broadcaster.new(formatters)
        broadcaster.options = @options
        return broadcaster
      end

      def formatter_class(format)
        if(builtin = BUILTIN_FORMATS[format])
          constantize(builtin)
        else
          constantize(format)
        end
      end

      def files_to_require
        requires = @options[:require] || feature_dirs
        files = requires.map do |path|
          path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
          path = path.gsub(/\/$/, '') # Strip trailing slash.
          File.directory?(path) ? Dir["#{path}/**/*.rb"] : path
        end.flatten.uniq
        sorted_files = files.sort { |a,b| (b =~ %r{/support/} || -1) <=>  (a =~ %r{/support/} || -1) }.reject{|f| f =~ /^http/}
        env_files = sorted_files.select {|f| f =~ %r{/support/env.rb} }
        files = env_files + sorted_files.reject {|f| f =~ %r{/support/env.rb} }
        remove_excluded_files_from(files)
        files.reject! {|f| f =~ %r{/support/env.rb} } if @options[:dry_run]
        files
      end

      def feature_files
        potential_feature_files = @paths.map do |path|
          path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
          path = path.chomp('/')
          File.directory?(path) ? Dir["#{path}/**/*.feature"] : path
        end.flatten.uniq
        remove_excluded_files_from(potential_feature_files)
        potential_feature_files
      end

    protected

      def remove_excluded_files_from(files)
        files.reject! {|path| @options[:excludes].detect {|pattern| path =~ pattern } }
      end

      def feature_dirs
        @paths.map { |f| File.directory?(f) ? f : File.dirname(f) }.uniq
      end

      def constantize(camel_cased_word)
        begin
          names = camel_cased_word.split('::')
          names.shift if names.empty? || names.first.empty?

          constant = Object
          names.each do |name|
            constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
          end
          constant
        rescue NameError
          require underscore(camel_cased_word)
          retry
        end
      end

      # Snagged from active_support
      def underscore(camel_cased_word)
        camel_cased_word.to_s.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end

      def expand_profiles_into_args
        while (profile_index = @args.index(PROFILE_SHORT_FLAG) || @args.index(PROFILE_LONG_FLAG)) do
          @args.delete_at(profile_index)
          @args[profile_index] = args_from_profile(@args[profile_index])
          @args.flatten!
        end
      end

      def args_from_profile(profile)
        unless cucumber_yml.has_key?(profile)
          raise(<<-END_OF_ERROR)
Could not find profile: '#{profile}'

Defined profiles in cucumber.yml:
  * #{cucumber_yml.keys.join("\n  * ")}
        END_OF_ERROR
        end

        args_from_yml = cucumber_yml[profile] || ''

        case(args_from_yml)
          when String
            raise "The '#{profile}' profile in cucumber.yml was blank.  Please define the command line arguments for the '#{profile}' profile in cucumber.yml.\n" if args_from_yml =~ /^\s*$/
            args_from_yml = args_from_yml.split(' ')
          when Array
            raise "The '#{profile}' profile in cucumber.yml was empty.  Please define the command line arguments for the '#{profile}' profile in cucumber.yml.\n" if args_from_yml.empty?
          else
            raise "The '#{profile}' profile in cucumber.yml was a #{args_from_yml.class}. It must be a String or Array"
        end
        args_from_yml
      end

      def cucumber_yml
        return @cucumber_yml if @cucumber_yml
        unless File.exist?('cucumber.yml')
          raise(YmlLoadError,"cucumber.yml was not found.  Please refer to cucumber's documentation on defining profiles in cucumber.yml.  You must define a 'default' profile to use the cucumber command without any arguments.\nType 'cucumber --help' for usage.\n")
        end

        require 'yaml'
        begin
          @cucumber_yml = YAML::load(IO.read('cucumber.yml'))
        rescue StandardError => e
          raise(YmlLoadError,"cucumber.yml was found, but could not be parsed. Please refer to cucumber's documentation on correct profile usage.\n")
        end

        if @cucumber_yml.nil? || !@cucumber_yml.is_a?(Hash)
          raise(YmlLoadError,"cucumber.yml was found, but was blank or malformed. Please refer to cucumber's documentation on correct profile usage.\n")
        end

        return @cucumber_yml
      end

      def list_keywords_and_exit(lang)
        unless Cucumber::LANGUAGES[lang]
          raise("No language with key #{lang}")
        end
        LanguageHelpFormatter.list_keywords(@out_stream, lang)
        Kernel.exit
      end

      def list_languages_and_exit
        LanguageHelpFormatter.list_languages(@out_stream)
        Kernel.exit
      end

      def parse_drb
        @drb = @args.delete(DRB_FLAG) ? true : false
      end

      def default_options
        {
          :strict       => false,
          :require      => nil,
          :lang         => 'en',
          :dry_run      => false,
          :formats      => {},
          :excludes     => [],
          :include_tags => [],
          :exclude_tags => [],
          :name_regexps => [],
          :diff_enabled => true
        }
      end
    end

  end
end
