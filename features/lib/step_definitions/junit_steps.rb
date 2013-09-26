Then(/^the junit output file "(.*?)" should contain:$/) do |actual_file, text|
  actual = IO.read(current_dir + '/' + actual_file)
  actual = replace_junit_duration(actual)
  actual.should == text
end

module JUnitHelper
  def replace_junit_duration(s)
    s.gsub(/\d+\.\d\d+/m, '')
  end
end

World(JUnitHelper)
