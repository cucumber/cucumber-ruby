# encoding: utf-8

World do
  def calc
    @calc ||= Calculator.new
  end
end