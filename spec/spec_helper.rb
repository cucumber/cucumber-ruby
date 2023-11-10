# frozen_string_literal: true

ENV['CUCUMBER_COLORS'] = nil
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'simplecov_setup'
require 'cucumber'

RSpec.configure do |c|
  c.before { Cucumber::Term::ANSIColor.coloring = true }
end
