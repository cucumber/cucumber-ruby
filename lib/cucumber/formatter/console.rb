require 'cucumber/formatter/ansicolor'

module Cucumber
  module Formatter
    module Console
      extend ANSIColor
      FORMATS = Hash.new{|hash, format| hash[format] = method(format).to_proc}

      def format_string(string, status)
        fmt = format_for(status)
        if Proc === fmt
          fmt.call(string)
        else
          fmt % string
        end
      end

      def print_summary(io, features)
        io.puts
        io.puts
        
        io.puts dump_count(features.scenarios.length, "scenario")

        pending_count = features.scenarios.select{|scenario| scenario.pending?}.length
        if pending_count > 0
          pending_count_string = dump_count(pending_count, "scenario", "pending")
          io.puts format_string(pending_count_string, :pending)
        end
        
        [:failed, :skipped, :undefined, :pending, :passed].each do |status|
          if features.step_count[status] > 0
            count_string = dump_count(features.step_count[status], "step", status.to_s)
            io.puts format_string(count_string, status)
          end
        end
      end

    private

      def dump_count(count, what, state=nil)
        [count, "#{what}#{count == 1 ? '' : 's'}", state].compact.join(" ")
      end

      def print_pending_messages
        @io.puts "Pending Notes:"
        @pending_messages.each_value do |message|
          @io.puts message
        end
        @io.puts
      end

      def format_for(*keys)
        key = keys.join('_').to_sym
        fmt = FORMATS[key]
        raise "No format for #{key.inspect}: #{FORMATS.inspect}" if fmt.nil?
        fmt
      end
    end
  end
end