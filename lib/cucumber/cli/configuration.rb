module Cucumber
  module Cli
    class YmlLoadError < StandardError; end

    class Configuration
      FORMATS = %w{pretty profile progress rerun}
      DEFAULT_FORMAT = 'pretty'
    
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
        @args = args
        return parse_args_from_profile('default') if @args.empty?
        @args.extend(::OptionParser::Arguable)
      
        @args.options do |opts|
          opts.banner = ["Usage: cucumber [options] [ [FILE|DIR|URL][:LINE[:LINE]*] ]+", "",
            "Examples:",
            "cucumber examples/i18n/en/features",
            "cucumber --language it examples/i18n/it/features/somma.feature:6:98:113",
            "cucumber -n -i http://rubyurl.com/eeCl", "", "",
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
              list_keywords_and_exit(v)
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
            "TAGS must be comma-separated without spaces. Prefix tags with ~ to",
            "exclude features or scenarios having that tag. Tags can be specified",
            "with or without the @ prefix.") do |v|
            @options[:include_tags], @options[:exclude_tags] = *parse_tags(v)
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
          opts.on("-n", "--no-source", 
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
          opts.on("-v", "--verbose", "Show the files and features loaded.") do
            @options[:verbose] = true
          end
          opts.on("-g", "--guess", "Guess best match for Ambiguous steps.") do
            @options[:guess] = true
          end
          opts.on("--no-diff", "Disable diff output on failing expectations.") do
            @options[:diff_enabled] = false
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

        # Whatever is left after option parsing is the FILE arguments
        @paths += args
      end
    
      def verbose?
        @options[:verbose]
      end
    
      def strict?
        @options[:strict]
      end
      
      def guess?
        @options[:guess]
      end
    
      def diff_enabled?
        @options[:diff_enabled]
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
        includes = includes.map{|tag| tag =~ /^@(.*)/ ? $1 : tag}
        excludes = excludes.map{|tag| tag =~ /^@(.*)/ ? $1 : tag}
        [includes, excludes]
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
        
          begin
            formatter_class = formatter_class(format)
            formatter_class.new(step_mother, out, @options)
          rescue Exception => e
            exit_with_error("Error creating formatter: #{format}", e)
          end
        end
      
        broadcaster = Broadcaster.new(formatters)
        broadcaster.options = @options
        return broadcaster
      end
    
      def formatter_class(format)
        case format
          when 'html'     then Formatter::Html
          when 'pretty'   then Formatter::Pretty
          when 'profile'  then Formatter::Profile
          when 'progress' then Formatter::Progress
          when 'rerun'    then Formatter::Rerun
          when 'usage'    then Formatter::Usage
        else
          constantize(format)
        end
      end
    
      def files_to_require
        requires = @options[:require] || feature_dirs
        files = requires.map do |path|
          path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
          File.directory?(path) ? Dir["#{path}/**/*.rb"] : path
        end.flatten.uniq
        sorted_files = files.sort { |a,b| (b =~ %r{/support/} || -1) <=>  (a =~ %r{/support/} || -1) }.reject{|f| f =~ /^http/}
        env_files = sorted_files.select {|f| f =~ %r{/support/env.rb} }
        files = env_files + sorted_files.reject {|f| f =~ %r{/support/env.rb} }
        files.reject! {|f| f =~ %r{/support/env.rb} } if @options[:dry_run]
        files
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
    
    protected
  
      def feature_dirs
        feature_files.map { |f| File.directory?(f) ? f : File.dirname(f) }.uniq
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
          parse!(args_from_yml.split(' '))
        end

      rescue YmlLoadError => e
        exit_with_error(e.message)
      end
    
      def cucumber_yml
        return @cucumber_yml if @cucumber_yml
        unless File.exist?('cucumber.yml')
          raise(YmlLoadError,"cucumber.yml was not found.  Please refer to cucumber's documentation on defining profiles in cucumber.yml.  You must define a 'default' profile to use the cucumber command without any arguments.\nType 'cucumber --help' for usage.\n")
        end

        require 'yaml'
        begin
          @cucumber_yml = YAML::load(IO.read('cucumber.yml'))
        rescue Exception => e
          raise(YmlLoadError,"cucumber.yml was found, but could not be parsed. Please refer to cucumber's documentation on correct profile usage.\n")
        end

        if @cucumber_yml.nil? || !@cucumber_yml.is_a?(Hash)
          raise(YmlLoadError,"cucumber.yml was found, but was blank or malformed. Please refer to cucumber's documentation on correct profile usage.\n")
        end

        return @cucumber_yml
      end
    
      def list_keywords_and_exit(lang)
        unless Cucumber::LANGUAGES[lang]
          exit_with_error("No language with key #{lang}")
        end
        LanguageHelpFormatter.list_keywords(@out_stream, lang)
        Kernel.exit
      end
    
      def list_languages
        LanguageHelpFormatter.list_languages(@out_stream)
        Kernel.exit
      end
    
      def default_options
        {
          :strict         => false,
          :require        => nil,
          :lang           => 'en',
          :dry_run        => false,
          :formats        => {},
          :excludes       => [],
          :include_tags   => [],
          :exclude_tags   => [],
          :scenario_names => [],
          :diff_enabled   => true
        }
      end
    
      def exit_with_error(error_message, e=nil)
        @error_stream.puts(error_message)
        if e
          @error_stream.puts("#{e.message} (#{e.class})")
          @error_stream.puts(e.backtrace.join("\n"))
        end
        Kernel.exit 1
      end
    end
  
  end
end
