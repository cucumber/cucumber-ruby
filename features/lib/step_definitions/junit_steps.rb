Then(/^the junit output file "(.*?)" should contain:$/) do |actual_file, text|
  actual = IO.read(current_dir + '/' + actual_file)
  actual = replace_junit_time(actual)
  actual.should == text
end

module JUnitHelper
  def replace_junit_time(s)
    s.gsub(/\d+\.\d\d+/m, '0.05')
  end
end

World(JUnitHelper)
