class Array #:nodoc:
  def rotate(n)
    # Translate a negative index to a positive one.
    n = length + n if n < 0
    
    self[n, length - n] + self[0, n]
  end unless method_defined? :rotate
end
