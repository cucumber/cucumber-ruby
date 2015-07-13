require 'cucumber/platform'


module Cucumber
  module Formatter
    class BacktraceFilter
      def initialize(exception)
        @exception = exception
        @backtrace_filter_patterns = \
          [/vendor\/rails|lib\/cucumber|bin\/cucumber:|lib\/rspec|gems\/|minitest|test\/unit|.gem\/ruby|lib\/ruby/]

        if(::Cucumber::JRUBY)
          @backtrace_filter_patterns << /org\/jruby/
        end

        @pwd_pattern = /#{::Regexp.escape(::Dir.pwd)}\//m
      end

      def exception
        return @exception if ::Cucumber.use_full_backtrace
        @exception.backtrace.each{|line| line.gsub!(@pwd_pattern, "./")}

        filtered = (@exception.backtrace || []).reject do |line|
          @backtrace_filter_patterns.detect { |p| line =~ p }
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
