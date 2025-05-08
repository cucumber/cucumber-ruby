# frozen_string_literal: true

require 'cucumber/platform'

module Cucumber
  module Formatter
    @backtrace_filters = %w[
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

    @backtrace_filters << RbConfig::CONFIG['rubyarchdir'] if RbConfig::CONFIG['rubyarchdir']
    @backtrace_filters << RbConfig::CONFIG['rubylibdir'] if RbConfig::CONFIG['rubylibdir']

    @backtrace_filters << 'org/jruby/' if ::Cucumber::JRUBY
    @backtrace_filters << '<internal:' if RUBY_ENGINE == 'truffleruby'

    BACKTRACE_FILTER_PATTERNS = Regexp.new(@backtrace_filters.join('|'))

    class BacktraceFilter
      def initialize(exception)
        @exception = exception
      end

      def exception
        return @exception if ::Cucumber.use_full_backtrace

        backtrace = @exception.backtrace.map { |line| line.gsub(pwd_pattern, './') }

        filtered = (backtrace || []).reject do |line|
          line =~ BACKTRACE_FILTER_PATTERNS
        end

        if ::ENV['CUCUMBER_TRUNCATE_OUTPUT']
          filtered = filtered.map do |line|
            # Strip off file locations
            match = regexp_filter.match(line)
            match ? match[1] : line
          end
        end

        @exception.tap { |e| e.set_backtrace(filtered) }
      end

      private

      def pwd_pattern
        /#{::Regexp.escape(::Dir.pwd)}\//m
      end

      def regexp_filter
        ruby_greater_than_three_four? ? three_four_filter : three_three_filter
      end

      def ruby_greater_than_three_four?
        RUBY_VERSION.to_f >= 3.4
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
