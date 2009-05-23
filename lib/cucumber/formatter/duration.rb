module Cucumber
  module Formatter
    module Duration
      def format_duration(seconds)
        m, s = seconds.divmod(60)
        "#{m}m#{'%.3f' % s}s" 
      end
    end
  end
end
