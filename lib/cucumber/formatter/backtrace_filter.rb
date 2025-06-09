# frozen_string_literal: true

require 'cucumber/platform'

module Cucumber
  module Formatter
    class BacktraceFilter
      def initialize(exception)
        @exception = exception
        @backtrace_filters = standard_ruby_paths + dynamic_ruby_paths
      end

      def exception
        return @exception if ::Cucumber.use_full_backtrace

        backtrace = @exception.backtrace.map { |line| line.gsub(pwd_pattern, './') }
        filtered = backtrace.reject { |line| line.match?(backtrace_filter_patterns) }

        if ::ENV['CUCUMBER_TRUNCATE_OUTPUT']
          filtered = filtered.map do |line|
            # Strip off file locations
            match = regexp_filter.match(line)
            match ? match[1] : line
          end
        end

        @exception.tap { |error_object| error_object.set_backtrace(filtered) }
      end

      private

      def backtrace_filter_patterns
        Regexp.new(@backtrace_filters.join('|'))
      end

      def dynamic_ruby_paths
        [].tap do |paths|
          paths << RbConfig::CONFIG['rubyarchdir'] if RbConfig::CONFIG['rubyarchdir']
          paths << RbConfig::CONFIG['rubylibdir'] if RbConfig::CONFIG['rubylibdir']

          paths << 'org/jruby/' if ::Cucumber::JRUBY
          paths << '<internal:' if RUBY_ENGINE == 'truffleruby'
        end
      end

      def pwd_pattern
        /#{::Regexp.escape(::Dir.pwd)}\//m
      end

      def regexp_filter
        ruby_greater_than_three_four? ? three_four_filter : three_three_filter
      end

      def ruby_greater_than_three_four?
        RUBY_VERSION.to_f >= 3.4
      end

      def standard_ruby_paths
        %w[
          /vendor/rails
          lib/cucumber
          bin/cucumber:
          lib/rspec
          gems/
          site_ruby/
          minitest
          test/unit
          .gem/ruby
          bin/bundle
          rdebug-ide
        ]
      end

      def three_four_filter
        /(.*):in '/
      end

      def three_three_filter
        /(.*):in `/
      end
    end
  end
end
