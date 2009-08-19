class String #:nodoc:
  def indent(n)
    if n >= 0
      gsub(/^/, ' ' * n)
    else
      gsub(/^ {0,#{-n}}/, "")
    end
  end
  
  # re.source.gsub(/\([^)]*\)/, '$var')
  # Cumulative #sub
  def subs(re, *args)
    args.inject(self) do |s,arg|
      s.sub(re, arg)
    end
  end

  # TODO: Use subs instead...
  def gzub(regexp, format=nil, &proc)
    md = match(regexp)
    raise "#{self.inspect} doesn't match #{regexp.inspect}" if md.nil?
    
    s = dup
    pos = 0
    md.captures.each_with_index do |m, n|
      replacement = if block_given?
        proc.call(m)
      elsif Proc === format
        format.call(m)
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

  if (Cucumber::JRUBY && Cucumber::RAILS) || Cucumber::RUBY_1_9
    # Workaround for http://tinyurl.com/55uu3u 
    alias jlength length
  else
    require 'jcode'
  end
end
