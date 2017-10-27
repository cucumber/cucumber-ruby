# frozen_string_literal: true
Then('the junit output file {string} should contain:') do |actual_file, text|
  actual = IO.read(current_dir + '/' + actual_file)
  actual = replace_junit_time(actual)
  expect(actual).to eq text
end

module JUnitHelper
  def replace_junit_time(s)
    s.gsub(/\d+\.\d\d+/m, '0.05')
  end
end

World(JUnitHelper)
