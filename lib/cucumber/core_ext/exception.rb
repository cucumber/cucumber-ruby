class Exception
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
    return (backtrace || []) if @@cucumber_full_backtrace
    (backtrace || []).map {|b| b.split("\n") }.flatten.reject do |line|
      CUCUMBER_FILTER_PATTERNS.detect{|p| line =~ p}
    end.map { |line| line.strip }
  end
end