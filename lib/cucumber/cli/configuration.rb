require 'logger'
require 'cucumber/cli/options'
require 'cucumber/cli/rerun_file'
require 'cucumber/constantize'
require 'gherkin/tag_expression'

module Cucumber
  module Cli
    class YmlLoadError < StandardError; end
    class ProfilesNotDefinedError < YmlLoadError; end
    class ProfileNotFound < StandardError; end

    class Configuration
      include Constantize

      attr_reader :out_stream

      def initialize(out_stream = STDOUT, error_stream = STDERR)
        @out_stream   = out_stream
        @error_stream = error_stream
        @options = Options.new(@out_stream, @error_stream, :default_profile => 'default')
      end

      def parse!(args)
        @args = args
        @options.parse!(args)
        arrange_formats
        raise("You can't use both --strict and --wip") if strict? && wip?
        # todo: remove
        @options[:tag_expression] = Gherkin::TagExpression.new(@options[:tag_expressions])
        set_environment_variables
      end

      def verbose?
        @options[:verbose]
      end

      def randomize?
        @options[:order] == 'random'
      end

      def seed
        Integer(@options[:seed] || rand(0xFFFF))
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

      def dry_run?
        @options[:dry_run]
      end

      def expand?
        @options[:expand]
      end

      def snippet_type
        @options[:snippet_type] || :regexp
      end

      def formatter_class(format)
        if(builtin = Options::BUILTIN_FORMATS[format])
          constantize(builtin[0])
        else
          constantize(format)
        end
      end

      def all_files_to_load
        files = require_dirs.map do |path|
          path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
          path = path.gsub(/\/$/, '') # Strip trailing slash.
          File.directory?(path) ? Dir["#{path}/**/*"] : path
        end.flatten.uniq
        remove_excluded_files_from(files)
        files.reject! {|f| !File.file?(f)}
        files.reject! {|f| File.extname(f) == '.feature' }
        files.reject! {|f| f =~ /^http/}
        files.sort
      end

      def step_defs_to_load
        all_files_to_load.reject {|f| f =~ %r{/support/} }
      end

      def support_to_load
        support_files = all_files_to_load.select {|f| f =~ %r{/support/} }
        env_files = support_files.select {|f| f =~ %r{/support/env\..*} }
        other_files = support_files - env_files
        @options[:dry_run] ? other_files : env_files + other_files
      end

      def feature_files
        potential_feature_files = with_default_features_path(paths).map do |path|
          path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
          path = path.chomp('/')
          if File.directory?(path)
            Dir["#{path}/**/*.feature"].sort
          elsif RerunFile.can_read?(path)
            RerunFile.new(path).features
          else
            path
          end
        end.flatten.uniq
        remove_excluded_files_from(potential_feature_files)
        potential_feature_files
      end


      def feature_dirs
        dirs = paths.map { |f| File.directory?(f) ? f : File.dirname(f) }.uniq
        dirs.delete('.') unless paths.include?('.')
        with_default_features_path(dirs)
      end

      def log
        logger = Logger.new(@out_stream)
        logger.formatter = LogFormatter.new
        logger.level = Logger::INFO
        logger.level = Logger::DEBUG if self.verbose?
        logger
      end

      # todo: remove
      def tag_expression
        Gherkin::TagExpression.new(@options[:tag_expressions])
      end

      def tag_limits
        tag_expression.limits.to_hash
      end

      def tag_expressions
        @options[:tag_expressions]
      end

      def name_regexps
        @options[:name_regexps]
      end

      def filters
        @options.filters
      end

      def formats
        @options[:formats]
      end

      def options
        warn("Deprecated: Configuration#options will be removed from the next release of Cucumber. Please use the configuration object directly instead.")
        @options
      end

      def paths
        @options[:paths]
      end

      def formatter_factories
        @options[:formats].map do |format_and_out|
          format = format_and_out[0]
          path_or_io = format_and_out[1]
          begin
            factory = formatter_class(format)
            yield factory, path_or_io, @options
          rescue Exception => e
            e.message << "\nError creating formatter: #{format}"
            raise e
          end
        end
      end

      private

      def default_features_paths
        ["features"]
      end

      def with_default_features_path(paths)
        return default_features_paths if paths.empty?
        paths
      end

      class LogFormatter < ::Logger::Formatter
        def call(severity, time, progname, msg)
          msg
        end
      end

      def set_environment_variables
        @options[:env_vars].each do |var, value|
          ENV[var] = value
        end
      end

      def arrange_formats
        @options[:formats] << ['pretty', @out_stream] if @options[:formats].empty?
        @options[:formats] = @options[:formats].sort_by{|f| f[1] == @out_stream ? -1 : 1}
        @options[:formats].uniq!
        @options.check_formatter_stream_conflicts()
      end

      def remove_excluded_files_from(files)
        files.reject! {|path| @options[:excludes].detect {|pattern| path =~ pattern } }
      end

      def require_dirs
        if @options[:require].empty?
          default_features_paths + Dir['vendor/{gems,plugins}/*/cucumber']
        else
          @options[:require]
        end
      end
    end
  end
end
