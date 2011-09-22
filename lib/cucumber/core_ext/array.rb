class Array #:nodoc:
  def rotate(n)
    self[n, length - n] + self[0, n]
  end unless method_defined? :rotate
end
