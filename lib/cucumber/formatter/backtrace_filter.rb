# frozen_string_literal: true
require 'cucumber/platform'


module Cucumber
  module Formatter
    BACKTRACE_FILTER_PATTERNS = \
      [/vendor\/rails|lib\/cucumber|bin\/cucumber:|lib\/rspec|gems\/|minitest|test\/unit|.gem\/ruby|lib\/ruby/]

    if(::Cucumber::JRUBY)
      BACKTRACE_FILTER_PATTERNS << /org\/jruby/
    end

    class BacktraceFilter
      def initialize(exception)
        @exception = exception
      end

      def exception
        return @exception if ::Cucumber.use_full_backtrace

        pwd_pattern = /#{::Regexp.escape(::Dir.pwd)}\//m
        backtrace = @exception.backtrace.map { |line| line.gsub(pwd_pattern, "./") }

        filtered = (backtrace || []).reject do |line|
          BACKTRACE_FILTER_PATTERNS.detect { |p| line =~ p }
        end

        if ::ENV['CUCUMBER_TRUNCATE_OUTPUT']
          # Strip off file locations
          filtered = filtered.map do |line|
            line =~ /(.*):in `/ ? $1 : line
          end
        end

        @exception.set_backtrace(filtered)
        @exception
      end
    end

  end
end
