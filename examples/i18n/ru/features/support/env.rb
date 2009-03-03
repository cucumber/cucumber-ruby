$KCODE='u'

World do  
  def calc
    @calc ||= Calculator.new
  end
end