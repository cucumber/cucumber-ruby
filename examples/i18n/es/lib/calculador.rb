# frozen_string_literal: true

class Calculador
  def push(n)
    @args ||= []
    @args << n
  end

  def add
    @args.inject(0) { |n, sum| sum + n }
  end

  def divide
    @args[0].to_f / @args[1]
  end
end
