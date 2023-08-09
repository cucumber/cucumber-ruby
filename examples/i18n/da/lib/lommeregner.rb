# frozen_string_literal: true

class Lommeregner
  def push(n)
    @args ||= []
    @args << n
  end

  def add
    @args.inject(0) { |n, sum| sum + n }
  end
end
