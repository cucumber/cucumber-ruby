# frozen_string_literal: true

class Kalkilatris
  def push(n)
    @args ||= []
    @args << n
  end

  def ajoute
    @args.inject(0) { |n, sum| sum + n }
  end

  def divize
    @args[0].to_f / @args[1]
  end
end
