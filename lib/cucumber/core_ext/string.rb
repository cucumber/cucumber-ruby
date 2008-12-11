class String
  def gzub(regexp, format=nil, &proc)
    md = match(regexp)
    raise "#{self.inspect} doesn't match #{regexp.inspect}" if md.nil?
    
    s = dup
    pos = 0
    md.captures.each_with_index do |m, n|
      replacement = if block_given?
        proc.call(m)
      else
        format % m
      end
      
      if md.offset(n+1)[0]
        s[md.offset(n+1)[0] + pos, m.length] = replacement
        pos += replacement.length - m.length
      end
    end
    s
  end

  if ($CUCUMBER_JRUBY && $CUCUMBER_RAILS)
    # Workaround for http://tinyurl.com/55uu3u 
    alias jlength length
  else
    require 'jcode'
  end
end
