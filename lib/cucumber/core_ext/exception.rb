class Exception
  CUCUMBER_STRIP_ADJUSTMENT = 2
  
  CUCUMBER_FILTER_PATTERNS = [
    /vendor\/rails/, 
    /vendor\/plugins\/cucumber/, 
    /spec\/expectations/, 
    /spec\/matchers/
  ]

  def self.cucumber_full_backtrace=(v)
    @@cucumber_full_backtrace = v
  end
  self.cucumber_full_backtrace = false

  def cucumber_backtrace
    @cucumber_backtrace ||= if @@cucumber_full_backtrace
      backtrace || []
    else
      (backtrace || []).map {|b| b.split("\n") }.flatten.reject do |line|
        CUCUMBER_FILTER_PATTERNS.detect{|p| line =~ p}
      end.map { |line| line.strip }
    end
  end
  
  # Strips the backtrace from +line+ and down
  def cucumber_strip_backtrace!(line, last_line)
    line_pos = cucumber_backtrace.index(line)
    if line_pos
      cucumber_backtrace[line_pos-CUCUMBER_STRIP_ADJUSTMENT..-1] = nil
      cucumber_backtrace.compact!
      cucumber_backtrace[-1].gsub!(/`.*'/, "`#{last_line}'")
    else
      # This happens with rails, because they screw up the backtrace
      # before we get here (injecting erb stacktrace and such)
    end
  end
end