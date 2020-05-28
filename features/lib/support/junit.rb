module JUnitWorld
  def replace_junit_time(time)
    time.gsub(/\d+\.\d\d+/m, '0.05')
  end
end

World(JUnitWorld)
