require 'ostruct'

options = OpenStruct.new(:diff_format => :unified, :context_lines => 3)

begin
  # RSpec >=2.0
  require 'rspec/expectations'
  require 'rspec/expectations/differs/default'
  Rspec::Expectations.differ = ::Rspec::Expectations::Differs::Default.new(options)
rescue LoadError => try_rspec_1_2_4_or_higher
  begin
    require 'spec/expectations'
    require 'spec/runner/differs/default'
    Spec::Expectations.differ = Spec::Expectations::Differs::Default.new(options)
  rescue LoadError => give_up
  end
end
