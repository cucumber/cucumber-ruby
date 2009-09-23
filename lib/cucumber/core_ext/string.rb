class String #:nodoc:
  def indent(n)
    if n >= 0
      gsub(/^/, ' ' * n)
    else
      gsub(/^ {0,#{-n}}/, "")
    end
  end
  
  # TODO: Move to StepMatch
  # +groups+ is an array of 2-element arrays, where
  # the 1st element is the value of a regexp match group,
  # and the 2nd element is its start index.
  def gzub(groups, format=nil, &proc)
    s = dup
    offset = 0
    groups.each do |group|
      replacement = if block_given?
        proc.call(group.val)
      elsif Proc === format
        format.call(group.val)
      else
        format % group.val
      end
      
      s[group.start + offset, group.val.length] = replacement
      offset += replacement.length - group.val.length
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
