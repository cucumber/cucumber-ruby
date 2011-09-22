class Array #:nodoc:
  def rotate(n)
    [n, length - n] + [0, n]
  end unless method_defined? :rotate
end
