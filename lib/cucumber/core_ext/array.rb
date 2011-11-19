class Array #:nodoc:
  def rotate(n = 1)
    # Translate a negative index to a positive one.
    n += length while n < 0
    n -= length while n >= length
    
    self[n, length - n] + self[0, n]
  end unless method_defined? :rotate
end
