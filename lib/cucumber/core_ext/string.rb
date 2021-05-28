# frozen_string_literal: true

class String #:nodoc:
  def cucumber_indent(n)
    if n >= 0
      gsub(/^/, ' ' * n)
    else
      gsub(/^ {0,#{-n}}/, '')
    end
  end
end
